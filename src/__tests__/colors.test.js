const colors = require('../components/colors');

describe('Colors', () => {
  describe('Basic colors', () => {
    it('should have white color defined', () => {
      expect(colors.white).toBe('#ffffff');
    });

    it('should have black color defined', () => {
      expect(colors.black).toBe('#000000');
    });
  });

  describe('Charcoal color palette', () => {
    it('should have all charcoal shades defined', () => {
      expect(colors.charcoal).toBeDefined();
      expect(colors.charcoal[50]).toBe('#F2F2F2');
      expect(colors.charcoal[100]).toBe('#E5E5E5');
      expect(colors.charcoal[200]).toBe('#C9C9C9');
      expect(colors.charcoal[300]).toBe('#B0B0B0');
      expect(colors.charcoal[400]).toBe('#969696');
      expect(colors.charcoal[500]).toBe('#7D7D7D');
      expect(colors.charcoal[600]).toBe('#616161');
      expect(colors.charcoal[700]).toBe('#474747');
      expect(colors.charcoal[800]).toBe('#383838');
      expect(colors.charcoal[850]).toBe('#2E2E2E');
      expect(colors.charcoal[900]).toBe('#1E1E1E');
      expect(colors.charcoal[950]).toBe('#121212');
    });
  });

  describe('Neutral color palette', () => {
    it('should have all neutral shades defined', () => {
      expect(colors.neutral).toBeDefined();
      expect(colors.neutral[50]).toBe('#FAFAFA');
      expect(colors.neutral[100]).toBe('#F5F5F5');
      expect(colors.neutral[200]).toBe('#F0EFEE');
      expect(colors.neutral[300]).toBe('#D4D4D4');
      expect(colors.neutral[400]).toBe('#A3A3A3');
      expect(colors.neutral[500]).toBe('#737373');
      expect(colors.neutral[600]).toBe('#525252');
      expect(colors.neutral[700]).toBe('#404040');
      expect(colors.neutral[800]).toBe('#262626');
      expect(colors.neutral[900]).toBe('#171717');
    });
  });

  describe('Primary color palette', () => {
    it('should have all primary shades defined', () => {
      expect(colors.primary).toBeDefined();
      expect(colors.primary[50]).toBe('#FFE2CC');
      expect(colors.primary[100]).toBe('#FFC499');
      expect(colors.primary[200]).toBe('#FFA766');
      expect(colors.primary[300]).toBe('#FF984C');
      expect(colors.primary[400]).toBe('#FF8933');
      expect(colors.primary[500]).toBe('#FF7B1A');
      expect(colors.primary[600]).toBe('#FF6C00');
      expect(colors.primary[700]).toBe('#E56100');
      expect(colors.primary[800]).toBe('#CC5600');
      expect(colors.primary[900]).toBe('#B24C00');
    });
  });

  describe('Success color palette', () => {
    it('should have all success shades defined', () => {
      expect(colors.success).toBeDefined();
      expect(colors.success[50]).toBe('#F0FDF4');
      expect(colors.success[100]).toBe('#DCFCE7');
      expect(colors.success[200]).toBe('#BBF7D0');
      expect(colors.success[300]).toBe('#86EFAC');
      expect(colors.success[400]).toBe('#4ADE80');
      expect(colors.success[500]).toBe('#22C55E');
      expect(colors.success[600]).toBe('#16A34A');
      expect(colors.success[700]).toBe('#15803D');
      expect(colors.success[800]).toBe('#166534');
      expect(colors.success[900]).toBe('#14532D');
    });
  });

  describe('Warning color palette', () => {
    it('should have all warning shades defined', () => {
      expect(colors.warning).toBeDefined();
      expect(colors.warning[50]).toBe('#FFFBEB');
      expect(colors.warning[100]).toBe('#FEF3C7');
      expect(colors.warning[200]).toBe('#FDE68A');
      expect(colors.warning[300]).toBe('#FCD34D');
      expect(colors.warning[400]).toBe('#FBBF24');
      expect(colors.warning[500]).toBe('#F59E0B');
      expect(colors.warning[600]).toBe('#D97706');
      expect(colors.warning[700]).toBe('#B45309');
      expect(colors.warning[800]).toBe('#92400E');
      expect(colors.warning[900]).toBe('#78350F');
    });
  });

  describe('Danger color palette', () => {
    it('should have all danger shades defined', () => {
      expect(colors.danger).toBeDefined();
      expect(colors.danger[50]).toBe('#FEF2F2');
      expect(colors.danger[100]).toBe('#FEE2E2');
      expect(colors.danger[200]).toBe('#FECACA');
      expect(colors.danger[300]).toBe('#FCA5A5');
      expect(colors.danger[400]).toBe('#F87171');
      expect(colors.danger[500]).toBe('#EF4444');
      expect(colors.danger[600]).toBe('#DC2626');
      expect(colors.danger[700]).toBe('#B91C1C');
      expect(colors.danger[800]).toBe('#991B1B');
      expect(colors.danger[900]).toBe('#7F1D1D');
    });
  });

  describe('Color palette structure', () => {
    it('should have all required color palettes', () => {
      expect(colors).toHaveProperty('white');
      expect(colors).toHaveProperty('black');
      expect(colors).toHaveProperty('charcoal');
      expect(colors).toHaveProperty('neutral');
      expect(colors).toHaveProperty('primary');
      expect(colors).toHaveProperty('success');
      expect(colors).toHaveProperty('warning');
      expect(colors).toHaveProperty('danger');
    });

    it('should have consistent shade structure for color palettes', () => {
      const expectedShades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
      const palettes = ['neutral', 'primary', 'success', 'warning', 'danger'];

      palettes.forEach((palette) => {
        expectedShades.forEach((shade) => {
          expect(colors[palette]).toHaveProperty(shade.toString());
          expect(typeof colors[palette][shade]).toBe('string');
          expect(colors[palette][shade]).toMatch(/^#[0-9A-F]{6}$/i);
        });
      });
    });

    it('should have charcoal palette with additional 850 and 950 shades', () => {
      const expectedShades = [
        50, 100, 200, 300, 400, 500, 600, 700, 800, 850, 900, 950,
      ];

      expectedShades.forEach((shade) => {
        expect(colors.charcoal).toHaveProperty(shade.toString());
        expect(typeof colors.charcoal[shade]).toBe('string');
        expect(colors.charcoal[shade]).toMatch(/^#[0-9A-F]{6}$/i);
      });
    });
  });
});
