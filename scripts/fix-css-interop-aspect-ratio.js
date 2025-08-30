/*
  Post-prebuild fix for react-native-css-interop aspect-ratio parsing
  - Adds options: ParseDeclarationOptionsWithValueWarning to parseAspectRatio signature if missing
  - Inserts null guard for aspectRatio?.ratio at the top of parseAspectRatio
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

function applyFix(content) {
  let changed = false;
  const logs = [];

  const fnMarker = 'function parseAspectRatio';
  const fnIdx = content.indexOf(fnMarker);
  if (fnIdx === -1) {
    logs.push('parseAspectRatio function not found; no changes applied');
  } else {
    const paramsStart = content.indexOf('(', fnIdx);
    const paramsEnd = findMatchingParen(content, paramsStart);
    if (paramsStart !== -1 && paramsEnd !== -1) {
      const paramList = content.slice(paramsStart + 1, paramsEnd);
      if (!/ParseDeclarationOptionsWithValueWarning/.test(paramList)) {
        const trimmed = paramList.trim();
        const needsComma = trimmed.length > 0 && !trimmed.endsWith(',');
        const insertion = (trimmed.length > 0 ? (needsComma ? ', ' : ' ') : '') +
          'options: ParseDeclarationOptionsWithValueWarning';
        const before = content.slice(0, paramsEnd);
        const after = content.slice(paramsEnd);
        content = before + insertion + after;
        changed = true;
        logs.push('Added options: ParseDeclarationOptionsWithValueWarning to parseAspectRatio signature');
      } else {
        logs.push('Signature already includes ParseDeclarationOptionsWithValueWarning');
      }

      // Recompute body start because content may have shifted
      const newParamsEnd = findMatchingParen(content, content.indexOf('(', fnIdx));
      const bodyStart = content.indexOf('{', newParamsEnd);
      if (bodyStart !== -1) {
        const nextChunk = content.slice(bodyStart + 1, bodyStart + 300);
        if (!/aspectRatio\.?\??ratio/.test(nextChunk) || !/return\s+null/.test(nextChunk)) {
          const guard = `\n  if (!aspectRatio?.ratio || aspectRatio.ratio.length === 0) {\n    return null;\n  }\n`;
          content = content.slice(0, bodyStart + 1) + guard + content.slice(bodyStart + 1);
          changed = true;
          logs.push('Inserted null-safety guard for aspectRatio?.ratio');
        } else {
          logs.push('Null-safety guard already present');
        }
      }
    }
  }

  // Update the call site inside the 'aspect-ratio' case
  const casePatterns = [
    'case "aspect-ratio"',
    "case 'aspect-ratio'",
  ];
  let caseIdx = -1;
  for (const pat of casePatterns) {
    caseIdx = content.indexOf(pat);
    if (caseIdx !== -1) break;
  }
  if (caseIdx !== -1) {
    // Define a small window for the case block
    const windowEnd = (() => {
      const nextCase = content.indexOf('case ', caseIdx + 5);
      const nextDefault = content.indexOf('default:', caseIdx + 5);
      let end = content.length;
      if (nextCase !== -1) end = Math.min(end, nextCase);
      if (nextDefault !== -1) end = Math.min(end, nextDefault);
      return end;
    })();

    const block = content.slice(caseIdx, windowEnd);
    const callRegex = /parseAspectRatio\(\s*declaration\.value(?!\s*,\s*parseOptions)/;
    if (callRegex.test(block)) {
      const updatedBlock = block.replace(
        /parseAspectRatio\(\s*declaration\.value\s*\)/g,
        'parseAspectRatio(declaration.value, parseOptions)'
      ).replace(
        /parseAspectRatio\(\s*declaration\.value\s*,\s*([^\)]*)\)/g,
        (m, rest) => m.includes('parseOptions') ? m : `parseAspectRatio(declaration.value, parseOptions${rest ? ', ' + rest : ''})`
      ).replace(
        /parseAspectRatio\(\s*declaration\.value\s*(?=,)/g,
        (m) => (m.includes('parseOptions') ? m : 'parseAspectRatio(declaration.value, parseOptions')
      );

      content = content.slice(0, caseIdx) + updatedBlock + content.slice(windowEnd);
      changed = true;
      logs.push("Ensured parseAspectRatio is called with parseOptions in 'aspect-ratio' case");
    } else {
      // If already has parseOptions, log it
      if (/parseAspectRatio\(\s*declaration\.value\s*,\s*parseOptions/.test(block)) {
        logs.push('Call site already includes parseOptions');
      } else {
        logs.push('Could not find parseAspectRatio(declaration.value ...) call in aspect-ratio case');
      }
    }
  } else {
    logs.push("'aspect-ratio' case not found; no call-site changes applied");
  }

  return { content, changed, logs };
}

(function main() {
  if (!fs.existsSync(TARGET)) {
    console.error(`Target file not found: ${TARGET}`);
    process.exit(1);
  }
  const original = fs.readFileSync(TARGET, 'utf8');
  const { content, changed, logs } = applyFix(original);
  logs.forEach((l) => console.log('[fix-css-interop]', l));
  if (changed) {
    fs.writeFileSync(TARGET, content, 'utf8');
    console.log('[fix-css-interop] Changes written to target file');
  } else {
    console.log('[fix-css-interop] No changes needed (already patched)');
  }
})();