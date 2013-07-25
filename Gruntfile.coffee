# Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  grunt.initConfig
    watch:
      stylus:
        files: ['src/**/*.styl']
        tasks: ['stylus']
      server:
        files: ['src/**/*.coffee']
        tasks: ['coffee']

    clean:
      dist: ['dist']
      components: ['components']

    bower:
      install:
        options:
          copy: false

    bower_postinst:
      dist:
        options:
          directory: 'components'
          components:
            'bootstrap': ['npm', {'make': 'bootstrap' }]

    stylus:
      app:
        files:
          'dist/public/stylesheets/style.css': 'src/public/stylesheets/style.styl'

    coffee:
      all:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'dist'
        ext: '.js'
        sourceMap: true

    copy:
      jade:
        files: [{
          expand: true
          dot: true
          cwd: 'src'
          dest: 'dist'
          src: ['**/*.jade']
        }]

    nodemon:
      lcm:
        options:
          cwd: 'dist'
          file: '../node_modules/.bin/lcm'
          args: ['server']

    concurrent:
      local:
        tasks: ['nodemon', 'watch']
        options:
          logConcurrentOutput: true

  grunt.registerTask 'components', [
    'clean:components',
    'bower',
    'bower_postinst'
  ]

  grunt.registerTask 'default', [
    'clean:dist',
    'coffee',
    'stylus',
    'copy',
    'concurrent'
  ]
