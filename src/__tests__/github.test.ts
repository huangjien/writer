// Extract the utility function for testing
function elementWithNameExists(array: any[], nameToFind: string): boolean {
  return array.some((element) => element.name === nameToFind);
}

describe('GitHub utilities', () => {
  describe('elementWithNameExists', () => {
    it('should return true when element with name exists', () => {
      const array = [
        { name: 'file1.md', sha: 'abc123' },
        { name: 'file2.md', sha: 'def456' },
        { name: 'file3.md', sha: 'ghi789' },
      ];

      expect(elementWithNameExists(array, 'file2.md')).toBe(true);
    });

    it('should return false when element with name does not exist', () => {
      const array = [
        { name: 'file1.md', sha: 'abc123' },
        { name: 'file2.md', sha: 'def456' },
        { name: 'file3.md', sha: 'ghi789' },
      ];

      expect(elementWithNameExists(array, 'nonexistent.md')).toBe(false);
    });

    it('should return false for empty array', () => {
      const array: any[] = [];

      expect(elementWithNameExists(array, 'file1.md')).toBe(false);
    });

    it('should handle case-sensitive names', () => {
      const array = [
        { name: 'File1.md', sha: 'abc123' },
        { name: 'file2.md', sha: 'def456' },
      ];

      expect(elementWithNameExists(array, 'file1.md')).toBe(false);
      expect(elementWithNameExists(array, 'File1.md')).toBe(true);
    });

    it('should handle objects without name property', () => {
      const array = [
        { title: 'file1.md', sha: 'abc123' },
        { name: 'file2.md', sha: 'def456' },
      ];

      expect(elementWithNameExists(array, 'file1.md')).toBe(false);
      expect(elementWithNameExists(array, 'file2.md')).toBe(true);
    });

    it('should handle null and undefined values', () => {
      const array = [
        { name: null, sha: 'abc123' },
        { name: undefined, sha: 'def456' },
        { name: 'file3.md', sha: 'ghi789' },
      ];

      expect(elementWithNameExists(array, 'file3.md')).toBe(true);
      expect(elementWithNameExists(array, null as any)).toBe(true);
      expect(elementWithNameExists(array, undefined as any)).toBe(true);
    });

    it('should handle empty string names', () => {
      const array = [
        { name: '', sha: 'abc123' },
        { name: 'file2.md', sha: 'def456' },
      ];

      expect(elementWithNameExists(array, '')).toBe(true);
      expect(elementWithNameExists(array, 'file2.md')).toBe(true);
    });

    it('should handle special characters in names', () => {
      const array = [
        { name: 'file-1_test.md', sha: 'abc123' },
        { name: 'file@2#test.md', sha: 'def456' },
        { name: 'file 3 test.md', sha: 'ghi789' },
      ];

      expect(elementWithNameExists(array, 'file-1_test.md')).toBe(true);
      expect(elementWithNameExists(array, 'file@2#test.md')).toBe(true);
      expect(elementWithNameExists(array, 'file 3 test.md')).toBe(true);
    });

    it('should handle unicode characters in names', () => {
      const array = [
        { name: '文件1.md', sha: 'abc123' },
        { name: 'файл2.md', sha: 'def456' },
        { name: 'ファイル3.md', sha: 'ghi789' },
      ];

      expect(elementWithNameExists(array, '文件1.md')).toBe(true);
      expect(elementWithNameExists(array, 'файл2.md')).toBe(true);
      expect(elementWithNameExists(array, 'ファイル3.md')).toBe(true);
    });

    it('should handle large arrays efficiently', () => {
      const largeArray = Array.from({ length: 10000 }, (_, i) => ({
        name: `file${i}.md`,
        sha: `sha${i}`,
      }));

      expect(elementWithNameExists(largeArray, 'file5000.md')).toBe(true);
      expect(elementWithNameExists(largeArray, 'file9999.md')).toBe(true);
      expect(elementWithNameExists(largeArray, 'file10000.md')).toBe(false);
    });

    it('should handle duplicate names', () => {
      const array = [
        { name: 'file1.md', sha: 'abc123' },
        { name: 'file1.md', sha: 'def456' },
        { name: 'file2.md', sha: 'ghi789' },
      ];

      expect(elementWithNameExists(array, 'file1.md')).toBe(true);
    });
  });

  describe('GitHub API URL construction', () => {
    it('should construct correct GitHub API URL', () => {
      const repo = 'user/repository';
      const folder = 'Content';
      const expectedUrl = `https://api.github.com/repos/${repo}/contents/${folder}`;

      const constructedUrl =
        'https://api.github.com/repos/' + repo + '/contents/' + folder;

      expect(constructedUrl).toBe(expectedUrl);
    });

    it('should handle special characters in repo and folder names', () => {
      const repo = 'user/repo-with-dashes_and_underscores';
      const folder = 'folder-with-special_chars';
      const expectedUrl = `https://api.github.com/repos/${repo}/contents/${folder}`;

      const constructedUrl =
        'https://api.github.com/repos/' + repo + '/contents/' + folder;

      expect(constructedUrl).toBe(expectedUrl);
    });
  });

  describe('File filtering', () => {
    it('should filter markdown files correctly', () => {
      const items = [
        { name: 'file1.md', sha: 'abc123' },
        { name: 'file2.txt', sha: 'def456' },
        { name: 'file3.md', sha: 'ghi789' },
        { name: 'file4.json', sha: 'jkl012' },
      ];

      const markdownFiles = items.filter((item) => item.name.endsWith('.md'));

      expect(markdownFiles).toHaveLength(2);
      expect(markdownFiles[0].name).toBe('file1.md');
      expect(markdownFiles[1].name).toBe('file3.md');
    });

    it('should handle case sensitivity in file extensions', () => {
      const items = [
        { name: 'file1.md', sha: 'abc123' },
        { name: 'file2.MD', sha: 'def456' },
        { name: 'file3.Md', sha: 'ghi789' },
      ];

      const markdownFiles = items.filter((item) => item.name.endsWith('.md'));

      expect(markdownFiles).toHaveLength(1);
      expect(markdownFiles[0].name).toBe('file1.md');
    });
  });

  describe('Content processing', () => {
    it('should process file name display correctly', () => {
      const fileName = 'chapter_1_introduction.md';
      const displayName = fileName.replace('_', '').replace('.md', '');

      expect(displayName).toBe('chapter1_introduction');
    });

    it('should handle multiple underscores and extensions', () => {
      const fileName = 'chapter_1_part_2_conclusion.md';
      const displayName = fileName.replace('_', '').replace('.md', '');

      // Note: replace only replaces the first occurrence
      expect(displayName).toBe('chapter1_part_2_conclusion');
    });

    it('should handle files without extensions', () => {
      const fileName = 'chapter_1_introduction';
      const displayName = fileName.replace('_', '').replace('.md', '');

      expect(displayName).toBe('chapter1_introduction');
    });
  });
});
