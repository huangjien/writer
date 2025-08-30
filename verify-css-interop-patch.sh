#!/bin/bash

# CSS Interop Patch Verification Script
# This script verifies that the react-native-css-interop patch is correctly applied

echo "=== CSS Interop Patch Verification ==="

# Check if the patch file exists
if [ ! -f "patches/react-native-css-interop+0.1.22.patch" ]; then
    echo "✗ Patch file not found: patches/react-native-css-interop+0.1.22.patch"
    exit 1
fi
echo "✓ Patch file exists"

# Check if the target file exists
TARGET_FILE="node_modules/react-native-css-interop/src/css-to-rn/parseDeclaration.ts"
if [ ! -f "$TARGET_FILE" ]; then
    echo "✗ Target file not found: $TARGET_FILE"
    exit 1
fi
echo "✓ Target file exists"

# Check for the function signature change (parseOptions parameter)
if grep -q "options: ParseDeclarationOptionsWithValueWarning" "$TARGET_FILE"; then
    echo "✓ Function signature updated with parseOptions parameter"
else
    echo "✗ Function signature not updated - patch not applied"
    echo "Expected: function parseAspectRatio(aspectRatio: any, options: ParseDeclarationOptionsWithValueWarning)"
    echo "Current function signature:"
    grep -A 2 "function parseAspectRatio" "$TARGET_FILE" || echo "Function not found"
    exit 1
fi

# Check for the null safety check
if grep -q "if (!aspectRatio.ratio || aspectRatio.ratio.length === 0)" "$TARGET_FILE"; then
    echo "✓ Null safety check present"
else
    echo "✗ Null safety check missing - this will cause TypeError"
    echo "Current parseAspectRatio function:"
    sed -n '2640,2655p' "$TARGET_FILE"
    exit 1
fi

# Check for the parseOptions call in parseDeclaration
if grep -A 5 'case "aspect-ratio"' "$TARGET_FILE" | grep -q "parseAspectRatio(declaration.value, parseOptions)"; then
    echo "✓ parseAspectRatio called with parseOptions parameter"
else
    echo "✗ parseAspectRatio not called with parseOptions parameter"
    echo "Current aspect-ratio case:"
    grep -A 5 -B 2 'case "aspect-ratio"' "$TARGET_FILE"
    exit 1
fi

echo "✓ All patch verifications passed!"
echo "The CSS interop patch is correctly applied and should prevent the TypeError."