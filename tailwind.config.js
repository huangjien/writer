/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        secondary: 'var(--color-secondary)',
        outstand: 'var(--color-outstand)',
      }, 
    },
  },
  future: {
    hoverOnlyWhenSupported: true,
  },
  plugins: [],
};
