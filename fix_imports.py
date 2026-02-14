#!/usr/bin/env python3
import sys
import re

filename = sys.argv[1]

with open(filename, "r") as f:
    content = f.read()

# Split into lines
lines = content.split("\n")

# Find all imports
imports = []
for i, line in enumerate(lines):
    if "import " in line or 'import "' in line:
        imports.append((i, line))

# Find duplicates (same module imported both ways)
# Pattern: package:writer/xxx vs import ../../../../xxx
duplicates = set()
for i1, line1 in imports:
    match1 = re.search(r"import 'package:writer/([^/]+)", line1[1])
    if not match1:
        continue

    for i2, line2 in imports:
        if i1 == i2:
            continue
        match2 = re.search(rf"import \.\.{{4}}/({match1.group(1)})", line2[1])
        if match2:
            duplicates.add(i1)
            print(f"Found duplicate import at line {i1 + 1}: {line1[1]}")
            print(f"Duplicate is at line {i2 + 1}: {line2[1]}")
            print(f"Removing line {i2 + 1}")

# Remove duplicates (keep the package import, remove the relative one)
for i in sorted(duplicates, reverse=True):
    del lines[i]

# Write back
with open(filename, "w") as f:
    f.write("\n".join(lines))

print(f"Fixed {filename}")
