#!/usr/bin/env python3
"""
Fix import paths in restructured feature files.

Files that were moved to subdirectories now have incorrect relative import paths.
This script fixes them by:
1. Replacing `import "\.\./\./\.\./\.\.\./` with `import ../../../`
2. Removing extra backslashes that sed might add
3. Handling nested subdirectory structures correctly
"""

import sys
import re


def fix_imports(filepath: str) -> None:
    """Fix imports in a file that was moved to a subdirectory."""
    with open(filepath, "r") as f:
        content = f.read()

    # Get the directory structure of this file
    # Count ../ to determine depth
    depth = filepath.count("../")

    # Get the current directory depth (0-based)
    # If depth is 0, file was at root (lib/), use old paths like ../../
    # If depth is 2, file was 1 level deep (lib/features/), use ../../../
    # If depth is 3, file was 2 levels deep (lib/features/screens/), use ../../

    # Fix imports based on new depth
    if depth == 2:  # In features/feature/screens/ (was at root, now 2 levels deep)
        # ../../../../ should become ../../../ (go up 3 levels to lib/)
        content = re.sub(
            r'import "\.\./\.\./\.\./|import \.\./\.,', "import ../../../", content
        )
    else:
        # Should not happen, but proceed anyway
        print(f"Error: {filepath}")
        return content


if __name__ == "__main__":
    sys.exit(1)


if __name__ == "__main__":
    main()
