const { createGlobPatternsForDependencies } = require('@nx/angular/tailwind');
const { join } = require('path');

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    join(__dirname, 'src/**/!(*.stories|*.spec).{ts,html}'),
    ...createGlobPatternsForDependencies(__dirname),
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Tons de superfície — Azul Marinho Escuro (AppColors.darkBg)
        graphite: {
          DEFAULT: '#0A1628', // Background principal do app
          50:  '#252A33',
          100: '#1B2638',     // darkSurfaceElevated
          200: '#131D2E',     // surface principal do app
          300: '#1F2A3D',     // border
          400: '#13171D',
          900: '#060D18',
        },
        // Acento corporativo (Azul Click - AppColors.primary)
        accent: {
          DEFAULT: '#1AAEEB',
          400: '#5BC6F2',
          500: '#1AAEEB',
          600: '#0E8FC4',
          700: '#0B729D',
        },
        // Alerta (AppColors.warning)
        warn: {
          DEFAULT: '#FFB020',
          500: '#FFB020',
          600: '#E69B19',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        soft: '0 1px 2px rgba(0,0,0,0.4), 0 4px 12px rgba(0,0,0,0.25)',
      },
    },
  },
  plugins: [],
};
