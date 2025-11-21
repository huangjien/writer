const fs = require('fs');
const path = require('path');
const os = require('os');

const gradleFilePath = path.join(os.homedir(), '.pub-cache', 'hosted', 'pub.dev', 'isar_flutter_libs-3.1.0+1', 'android', 'build.gradle');

fs.readFile(gradleFilePath, 'utf8', (err, data) => {
  if (err) {
    if (err.code === 'ENOENT') return;
    return console.log(err);
  }
  let result = data;
  if (!result.includes("namespace 'io.isar.flutter.libs'")) {
    result = result.replace(/android\s*{/g, "android {\n    namespace 'io.isar.flutter.libs'");
  }
  // Ensure compileSdkVersion is set to a modern level (fixes android:attr/lStar errors)
  // Replace any existing compileSdkVersion assignment to enforce 36
  if (/compileSdk(?:Version)?\s*[= ]\s*\S+/g.test(result)) {
    result = result.replace(/compileSdk(?:Version)?\s*[= ]\s*\S+/g, 'compileSdkVersion 36');
  } else {
    result = result.replace(/android\s*{\n([^}]*)/m, (m, p1) => {
      return `android {\n    compileSdkVersion 36\n${p1}`;
    });
  }
  fs.writeFile(gradleFilePath, result, 'utf8', (err) => {
    if (err) return console.log(err);
  });
});

const manifestPath = path.join(os.homedir(), '.pub-cache', 'hosted', 'pub.dev', 'isar_flutter_libs-3.1.0+1', 'android', 'src', 'main', 'AndroidManifest.xml');

fs.readFile(manifestPath, 'utf8', (err, data) => {
    if (err) {
        if (err.code === 'ENOENT') return;
        return console.log(err);
    }
    const result = data.replace('package="dev.isar.isar_flutter_libs"', '');
    fs.writeFile(manifestPath, result, 'utf8', (err) => {
        if (err) return console.log(err);
    });
});