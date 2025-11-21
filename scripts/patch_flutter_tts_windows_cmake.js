const fs = require('fs');
const path = require('path');

function findFilesToPatch() {
  const targets = [];
  console.log('Searching for CMakeLists.txt to patch...');

  // 1) Ephemeral plugin symlink in repo
  const ephemeral = path.join(
    __dirname,
    '..',
    'windows',
    'flutter',
    'ephemeral',
    '.plugin_symlinks',
    'flutter_tts',
    'windows',
    'CMakeLists.txt'
  );
  console.log(`Checking ephemeral path: ${ephemeral}`);
  if (fs.existsSync(ephemeral)) {
    targets.push(ephemeral);
    console.log(`Found ephemeral file: ${ephemeral}`);
  }

  // 2) Pub cache plugin source
  const pubCache = process.env.PUB_CACHE;
  console.log(`PUB_CACHE environment variable: ${pubCache}`);
  if (pubCache) {
    // hosted/pub.dev/flutter_tts-<version>/windows/CMakeLists.txt
    const hosted = path.join(pubCache, 'hosted', 'pub.dev');
    console.log(`Checking pub cache path: ${hosted}`);
    if (fs.existsSync(hosted)) {
      const entries = fs.readdirSync(hosted, { withFileTypes: true });
      for (const ent of entries) {
        if (ent.isDirectory() && ent.name.startsWith('flutter_tts-')) {
          const cmake = path.join(hosted, ent.name, 'windows', 'CMakeLists.txt');
          console.log(`Checking potential pub cache file: ${cmake}`);
          if (fs.existsSync(cmake)) {
            targets.push(cmake);
            console.log(`Found pub cache file: ${cmake}`);
          }
        }
      }
    }
  }
  console.log(`Found ${targets.length} files to patch.`);
  return targets;
}

function patchFile(filePath) {
  console.log(`Attempting to patch file for all known issues: ${filePath}`);
  let src = fs.readFileSync(filePath, 'utf8');
  let originalSrc = src;

  // 1. Fix the `ARGS install` parsing error
  if (src.includes('ARGS install')) {
    const lines = src.split(/\r?\n/);
    const newLines = [];
    for (const line of lines) {
      if (!line.includes('ARGS install')) {
        newLines.push(line);
      }
    }
    src = newLines.join('\n');
    console.log('Removed line containing "ARGS install".');
  }

  // 2. Fix the linker error by adding WindowsApp.lib
  const originalLine = 'target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)';
  const patchedLine = 'target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin WindowsApp.lib)';

  if (src.includes(originalLine)) {
    src = src.replace(originalLine, patchedLine);
    console.log('Added WindowsApp.lib to target_link_libraries.');
  }

  if (src !== originalSrc) {
    fs.writeFileSync(filePath, src);
    console.log(`File patched successfully: ${filePath}`);
    return true;
  }

  console.log(`File did not require patching: ${filePath}`);
  return false;
}

const files = findFilesToPatch();
let anyPatched = false;
if (files.length === 0) {
  console.log('No CMakeLists.txt files found to patch.');
}
for (const f of files) {
  try {
    const ok = patchFile(f);
    if (ok) anyPatched = true;
  } catch (e) {
    console.error(`Error patching file ${f}:`, e);
  }
}

if (anyPatched) {
  console.log('Patch script finished. At least one file was patched.');
} else {
  console.log('Patch script finished. No files required patching.');
}
process.exit(0);