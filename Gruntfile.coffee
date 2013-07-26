# Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  debugConfig =
    'async/lib': 'async.js'
    'backbone-amd': 'backbone.js'
    'backbone-validation/dist': 'backbone-validation-amd.js'
    'backbone.babysitter/lib/amd': 'backbone.babysitter.js'
    'backbone.marionette/lib/core/amd': 'backbone.marionette.js'
    'backbone.paginator/dist': 'backbone.paginator.js'
    'backbone.wreqr/lib/amd': 'backbone.wreqr.js'
    'bootstrap/bootstrap/js': 'bootstrap.js'
    'font-awesome/css': 'font-awesome.css'
    'jquery': 'jquery.js'
    'requirejs': 'require.js'
    'underscore-amd': 'underscore.js'
    'jade': 'runtime.js'

  debugFiles =
    for lib, file of debugConfig
      expand: true
      cwd: 'components/' + lib
      dest: 'dist/public/scripts'
      src: file

  viewsConfig =
    'header.*.jade': 'header.js'
    'users.*.jade': 'users.js'

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
        files: debugFiles

      jade:
        files: [{
          expand: true
          dot: true
          cwd: 'src'
          dest: 'dist'
          src: ['app/views/**/*.jade']
        }]

    jade:
      client:
        options:
          wrap: 'amd'
          runtime: false
          wrapDir: false
        files: [{
          expand: true
          cwd: 'src'
          dest: 'dist'
          src: ['public/views/**/*.jade']
          ext: '.js'
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
    'jade',
    'copy'
  ]

  grunt.registerTask 'default', [
    'dist',
    'concurrent'
  ]
