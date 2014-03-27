module.exports = {
  dist: {
    options: {
      cache: false
    },
    files: [{
      expand: true,
      cwd: '.tmp/public',
      src: '**/*.{png,gif,jpg,jpeg}',
      dest: 'dist/'
    }]
  }
};
