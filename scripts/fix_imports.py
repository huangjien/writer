#!/usr/bin/env python3
"""
Convert relative imports to absolute imports in Flutter/Dart project.
Converts patterns like:
  import '../state/xxx.dart';
  import '../../widgets/yyy.dart';
To:
  import 'package:writer/state/xxx.dart';
  import 'package:writer/widgets/yyy.dart';
"""

import os
import re
import sys
from pathlib import Path


def convert_relative_imports(file_path: Path, lib_dir: Path) -> tuple[int, list[str]]:
    """
    Convert relative imports to absolute imports in a single file.
    Returns (number_of_changes, list_of_changed_lines).
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    changes = []
    lines = content.split('\n')
    
    # Get the file's path relative to lib/
    try:
        file_rel_path = file_path.relative_to(lib_dir)
    except ValueError:
        return 0, []
    
    # Remove filename to get directory path
    file_dir_parts = list(file_rel_path.parts[:-1])
    
    for i, line in enumerate(lines, 1):
        # Match relative imports: import '../ or import '../../
        match = re.match(r"^import\s+('|\")((\.\./)+[^'\"]+)('|\");", line)
        if match:
            quote_start, rel_path, _, quote_end = match.groups()
            
            # Count the number of ../ to determine how many directories to go up
            num_parents = rel_path.count('../')
            
            # Calculate the target path
            # Start from file's directory, go up num_parents times, then add the rest
            target_parts = list(file_dir_parts)
            
            # Remove num_parents directories
            for _ in range(num_parents):
                if target_parts:
                    target_parts.pop()
            
            # Get the path after the ../ prefixes (e.g., "state/session_state.dart")
            path_after_parents = rel_path.replace('../', '')
            
            # Combine to get full path
            if target_parts:
                full_rel_path = '/'.join(target_parts + [path_after_parents])
            else:
                full_rel_path = path_after_parents
            
            # Create absolute import
            abs_import = f"import {quote_start}package:writer/{full_rel_path}{quote_end};"
            
            if abs_import != line:
                lines[i - 1] = abs_import
                changes.append(f"Line {i}: {line.strip()} -> {abs_import.strip()}")
    
    new_content = '\n'.join(lines)
    
    if new_content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return len(changes), changes
    
    return 0, []


def main():
    lib_dir = Path(__file__).parent.parent / 'lib'
    
    if not lib_dir.exists():
        print(f"Error: lib directory not found at {lib_dir}")
        sys.exit(1)
    
    # Find all .dart files
    dart_files = list(lib_dir.rglob('*.dart'))
    
    total_changes = 0
    files_changed = 0
    
    for dart_file in dart_files:
        num_changes, changes = convert_relative_imports(dart_file, lib_dir)
        if num_changes > 0:
            files_changed += 1
            total_changes += num_changes
            rel_path = dart_file.relative_to(lib_dir.parent)
            print(f"\n{rel_path}:")
            for change in changes:
                print(f"  {change}")
    
    print(f"\n{'='*60}")
    print(f"Summary: {files_changed} files changed, {total_changes} imports converted")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()
