/*
  Post-prebuild fix for react-native-css-interop aspect-ratio parsing
  - Adds options: ParseDeclarationOptionsWithValueWarning to parseAspectRatio signature if missing
  - Inserts null guard for aspectRatio?.ratio AFTER the declaration of `const aspectRatio = ...`
  - Ensures parseAspectRatio is called with (declaration.value, parseOptions) in the 'aspect-ratio' case
  Idempotent: safe to run multiple times
*/

const fs = require('fs');
const path = require('path');

const TARGET = path.join(
  process.cwd(),
  'node_modules',
  'react-native-css-interop',
  'src',
  'css-to-rn',
  'parseDeclaration.ts'
);

function findMatchingParen(text, startIndex) {
  let depth = 0;
  for (let i = startIndex; i < text.length; i++) {
    const ch = text[i];
    if (ch === '(') depth++;
    else if (ch === ')') {
      depth--;
      if (depth === 0) return i;
    }
  }
  return -1;
}

function findFunctionRegion(content) {
  // Supports two forms:
  // 1) function parseAspectRatio(...) { ... }
  // 2) const parseAspectRatio = (...) => { ... }
  const nameIdx = content.indexOf('parseAspectRatio');
  if (nameIdx === -1) return null;

  // Find the first '(' after the name for param list
  const paramsStart = content.indexOf('(', nameIdx);
  if (paramsStart === -1) return null;
  const paramsEnd = findMatchingParen(content, paramsStart);
  if (paramsEnd === -1) return null;

  // Find body start '{' after paramsEnd
  let bodyStart = content.indexOf('{', paramsEnd);
  if (bodyStart === -1) return null;

  // Naively find body end by simple brace matching from bodyStart
  let depth = 0;
  let bodyEnd = -1;
  for (let i = bodyStart; i < content.length; i++) {
    if (content[i] === '{') depth++;
    else if (content[i] === '}') {
      depth--;
      if (depth === 0) {
        bodyEnd = i;
        break;
      }
    }
  }
  if (bodyEnd === -1) return null;

  return { nameIdx, paramsStart, paramsEnd, bodyStart, bodyEnd };
}

function addOptionsParam(content, paramsStart, paramsEnd, logs) {
  const paramList = content.slice(paramsStart + 1, paramsEnd);
  if (/ParseDeclarationOptionsWithValueWarning/.test(paramList)) {
    logs.push('Signature already includes ParseDeclarationOptionsWithValueWarning');
    return { content, changed: false, paramsEnd };
  }

  const trimmed = paramList.trim();
  const needsComma = trimmed.length > 0 && !trimmed.endsWith(',');
  const insertion =
    (trimmed.length > 0 ? (needsComma ? ', ' : ' ') : '') +
    'options: ParseDeclarationOptionsWithValueWarning';

  const before = content.slice(0, paramsEnd);
  const after = content.slice(paramsEnd);
  const updated = before + insertion + after;
  const newParamsEnd = paramsEnd + insertion.length;
  logs.push('Added options: ParseDeclarationOptionsWithValueWarning to parseAspectRatio signature');
  return { content: updated, changed: true, paramsEnd: newParamsEnd };
}

function insertNullGuardAfterAspectRatioDecl(content, bodyStart, bodyEnd, logs) {
  const body = content.slice(bodyStart + 1, bodyEnd);
  const declRegex = /const\s+aspectRatio\s*=\s*[^;]+;/m;
  const declMatch = body.match(declRegex);
  if (!declMatch) {
    logs.push('Could not locate `const aspectRatio = ...;` declaration to insert guard');
    return { content, changed: false };
  }

  const guard = `\n  if (!aspectRatio?.ratio || aspectRatio.ratio.length === 0) {\n    return null;\n  }\n`;
  const declStartInBody = declMatch.index;
  const declEndInBody = declStartInBody + declMatch[0].length;

  // Check if guard already present right after declaration
  const afterDeclSlice = body.slice(declEndInBody, declEndInBody + guard.length + 20);
  if (/aspectRatio\?\.ratio/.test(afterDeclSlice) && /return\s+null/.test(afterDeclSlice)) {
    logs.push('Null-safety guard already present after aspectRatio declaration');
    return { content, changed: false };
  }

  const newBody =
    body.slice(0, declEndInBody) +
    guard +
    body.slice(declEndInBody);

  const updated = content.slice(0, bodyStart + 1) + newBody + content.slice(bodyEnd);
  logs.push('Inserted null-safety guard after aspectRatio declaration');
  return { content: updated, changed: true };
}

function ensureCallSiteUsesParseOptions(content, logs) {
  const casePatterns = [
    'case "aspect-ratio"',
    "case 'aspect-ratio'",
  ];
  let caseIdx = -1;
  for (const pat of casePatterns) {
    caseIdx = content.indexOf(pat);
    if (caseIdx !== -1) break;
  }
  if (caseIdx === -1) {
    logs.push("'aspect-ratio' case not found; no call-site changes applied");
    return { content, changed: false };
  }

  const windowEnd = (() => {
    const nextCase = content.indexOf('case ', caseIdx + 5);
    const nextDefault = content.indexOf('default:', caseIdx + 5);
    let end = content.length;
    if (nextCase !== -1) end = Math.min(end, nextCase);
    if (nextDefault !== -1) end = Math.min(end, nextDefault);
    return end;
  })();

  const block = content.slice(caseIdx, windowEnd);
  const hasOptions = /parseAspectRatio\(\s*declaration\.value\s*,\s*parseOptions/.test(block);
  const hasCall = /parseAspectRatio\(\s*declaration\.value/.test(block);

  if (!hasCall) {
    logs.push('No parseAspectRatio(declaration.value ...) call found in aspect-ratio case');
    return { content, changed: false };
  }

  if (hasOptions) {
    logs.push('Call site already includes parseOptions');
    return { content, changed: false };
  }

  const updatedBlock = block
    // parseAspectRatio(declaration.value)
    .replace(
      /parseAspectRatio\(\s*declaration\.value\s*\)/g,
      'parseAspectRatio(declaration.value, parseOptions)'
    )
    // parseAspectRatio(declaration.value, somethingElse) -> ensure parseOptions first
    .replace(
      /parseAspectRatio\(\s*declaration\.value\s*,\s*([^\)]*)\)/g,
      (m, rest) => {
        if (/\bparseOptions\b/.test(rest)) return m; // already has
        return `parseAspectRatio(declaration.value, parseOptions${rest ? ', ' + rest : ''})`;
      }
    );

  const updated = content.slice(0, caseIdx) + updatedBlock + content.slice(windowEnd);
  logs.push("Ensured parseAspectRatio is called with parseOptions in 'aspect-ratio' case");
  return { content: updated, changed: true };
}

function applyFix(original) {
  let content = original;
  let changed = false;
  const logs = [];

  const region = findFunctionRegion(content);
  if (!region) {
    logs.push('parseAspectRatio function region not found; no signature/guard changes applied');
  } else {
    // 1) Add options param if missing
    const r1 = addOptionsParam(content, region.paramsStart, region.paramsEnd, logs);
    if (r1.changed) {
      content = r1.content;
      changed = true;
      // If params changed, bodyStart/bodyEnd indexes likely shifted; recompute region
      const rAgain = findFunctionRegion(content);
      if (rAgain) {
        region.paramsStart = rAgain.paramsStart;
        region.paramsEnd = rAgain.paramsEnd;
        region.bodyStart = rAgain.bodyStart;
        region.bodyEnd = rAgain.bodyEnd;
      }
    }

    // 2) Insert null guard after aspectRatio declaration
    const r2 = insertNullGuardAfterAspectRatioDecl(content, region.bodyStart, region.bodyEnd, logs);
    if (r2.changed) {
      content = r2.content;
      changed = true;
      // bodyEnd may shift but we don't need it further
    }
  }

  // 3) Ensure call site uses parseOptions
  const r3 = ensureCallSiteUsesParseOptions(content, logs);
  if (r3.changed) {
    content = r3.content;
    changed = true;
  }

  return { content, changed, logs };
}

(function main() {
  console.log('[fix-css-interop] Target:', TARGET);
  if (!fs.existsSync(TARGET)) {
    console.error(`[fix-css-interop] Target file not found: ${TARGET}`);
    process.exit(1);
  }
  const original = fs.readFileSync(TARGET, 'utf8');
  const { content, changed, logs } = applyFix(original);
  logs.forEach((l) => console.log('[fix-css-interop]', l));
  if (changed) {
    fs.writeFileSync(TARGET, content, 'utf8');
    console.log('[fix-css-interop] Changes written to target file');
  } else {
    console.log('[fix-css-interop] No changes needed (already patched or patterns not found)');
  }
})();