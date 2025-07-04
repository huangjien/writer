import { images } from '../app/images';

describe('Images Module', () => {
  it('should export images object with required properties', () => {
    expect(images).toBeDefined();
    expect(typeof images).toBe('object');
  });

  it('should have logo property', () => {
    expect(images.logo).toBeDefined();
    expect(typeof images.logo).toBe('string'); // require() returns a string in Jest
  });

  it('should have wood property', () => {
    expect(images.wood).toBeDefined();
    expect(typeof images.wood).toBe('string'); // require() returns a string in Jest
  });

  it('should have all expected image properties', () => {
    const expectedProperties = ['logo', 'wood'];
    expectedProperties.forEach((prop) => {
      expect(images).toHaveProperty(prop);
    });
  });

  it('should not have unexpected properties', () => {
    const actualProperties = Object.keys(images);
    const expectedProperties = ['logo', 'wood'];
    expect(actualProperties).toEqual(
      expect.arrayContaining(expectedProperties)
    );
    expect(actualProperties.length).toBe(expectedProperties.length);
  });
});
