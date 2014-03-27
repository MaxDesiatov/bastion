module.exports = {
  compile: {
    files: [{
      expand: true,
      cwd: 'app/styles',
      src: ['**/*.styl', '!**/_*.styl'],
      dest: '.tmp/public/assets/',
      ext: '.css'
    }]
  }
};
