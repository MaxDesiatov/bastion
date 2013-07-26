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
      debug:
        files: [{
          expand: true
          cwd: 'components/async/lib'
          dest: 'dist/public/scripts'
          src: 'async.js'
        },
        {
          expand: true
          cwd: 'components/backbone-amd'
          dest: 'dist/public/scripts'
          src: 'backbone.js'
        },
        {
          expand: true
          cwd: 'components/backbone-validation/dist'
          dest: 'dist/public/scripts'
          src: 'backbone-validation-amd.js'
        },
        {
          expand: true
          cwd: 'components/backbone.babysitter/lib/amd'
          dest: 'dist/public/scripts'
          src: 'backbone.babysitter.js'
        },
        {
          expand: true
          cwd: 'components/backbone.marionette/lib/core/amd'
          dest: 'dist/public/scripts'
          src: 'backbone.marionette.js'
        },
        {
          expand: true
          cwd: 'components/backbone.paginator/dist'
          dest: 'dist/public/scripts'
          src: 'backbone.paginator.js'
        },
        {
          expand: true
          cwd: 'components/backbone.wreqr/lib/amd'
          dest: 'dist/public/scripts'
          src: 'backbone.wreqr.js'
        },
        {
          expand: true
          cwd: 'components/bootstrap/bootstrap/js'
          dest: 'dist/public/scripts'
          src: 'bootstrap.js'
        },
        {
          expand: true
          cwd: 'components/font-awesome/css'
          dest: 'dist/public/stylesheets'
          src: 'font-awesome.css'
        },
        {
          expand: true
          cwd: 'components/jquery'
          dest: 'dist/public/scripts'
          src: 'jquery.js'
        },
        {
          expand: true
          cwd: 'components/requirejs'
          dest: 'dist/public/scripts'
          src: 'require.js'
        },
        {
          expand: true
          cwd: 'components/underscore-amd'
          dest: 'dist/public/scripts'
          src: 'underscore.js'
        }]

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

  grunt.registerTask 'dist', [
    'clean:dist',
    'coffee',
    'stylus',
    'copy'
  ]

  grunt.registerTask 'default', [
    'dist',
    'concurrent'
  ]
