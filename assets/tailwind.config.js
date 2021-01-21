module.exports = {
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./js/**/*.js",
    './**/*.elm',
  ],
  darkMode: 'media', // or 'media' or 'class' or false
  theme: {
    extend: {
      gridTemplateRows: {
        // Simple 8 row grid
        '8': 'repeat(8, minmax(0, 1fr))',
      },
      gridTemplateCols: {
        // Simple 8 row grid
        '8': 'repeat(8, minmax(0, 1fr))',
      },
      width: {
        '1/8': '12.5%'
      },
      height: {
        '1/8': '12.5%'
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [
//    require('@tailwindcss/forms')
  ],
}
