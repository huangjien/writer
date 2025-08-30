/** @type {import('tailwindcss').Config} */
const colors = require('./src/components/colors');

module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        secondary: 'var(--color-secondary)',
        outstand: 'var(--color-outstand)',
        // Apple Glass Vision Colors
        glass: colors.glass,
        'glass-bg': colors.glassBackground,
        charcoal: colors.charcoal,
        neutral: colors.neutral,
      },
      backdropBlur: {
        'xs': '2px',
        'sm': '4px',
        'md': '8px',
        'lg': '12px',
        'xl': '16px',
        '2xl': '24px',
        '3xl': '40px',
      },
      backdropSaturate: {
        '25': '.25',
        '50': '.5',
        '75': '.75',
        '100': '1',
        '125': '1.25',
        '150': '1.5',
        '200': '2',
      },
      boxShadow: {
        'glass': '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
        'glass-lg': '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
        'glass-xl': '0 35px 60px -12px rgba(0, 0, 0, 0.3)',
      },
      borderRadius: {
        'glass': '16px',
        'glass-lg': '24px',
        'glass-xl': '32px',
      },
    },
  },
  future: {
    hoverOnlyWhenSupported: true,
  },
  plugins: [
    function({ addUtilities }) {
      const newUtilities = {
        '.glass-effect': {
          'background': 'rgba(255, 255, 255, 0.15)',
          'backdrop-filter': 'blur(10px) saturate(180%)',
          'border': '1px solid rgba(255, 255, 255, 0.2)',
          'border-radius': '16px',
          'box-shadow': '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
        },
        '.glass-effect-dark': {
          'background': 'rgba(255, 255, 255, 0.1)',
          'backdrop-filter': 'blur(10px) saturate(180%)',
          'border': '1px solid rgba(255, 255, 255, 0.15)',
          'border-radius': '16px',
          'box-shadow': '0 8px 32px 0 rgba(0, 0, 0, 0.25)',
        },
        '.glass-card': {
          'background': 'rgba(255, 255, 255, 0.25)',
          'backdrop-filter': 'blur(15px) saturate(200%)',
          'border': '1px solid rgba(255, 255, 255, 0.3)',
          'border-radius': '20px',
          'box-shadow': '0 12px 40px 0 rgba(31, 38, 135, 0.4)',
        },
        '.glass-modal': {
          'background': 'rgba(255, 255, 255, 0.35)',
          'backdrop-filter': 'blur(20px) saturate(180%)',
          'border': '1px solid rgba(255, 255, 255, 0.4)',
          'border-radius': '24px',
          'box-shadow': '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
        },
      };
      addUtilities(newUtilities);
    },
  ],
};
