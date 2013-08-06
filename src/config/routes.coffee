passport = require 'passport'

module.exports = ->
  @root 'pages#main'
  @get 'login', 'pages#login'
  @post 'login', passport.authenticate 'local',
    successRedirect: '/'
    failureRedirect: '/login'
  @get 'logout', 'pages#logout'

  @resources 'users', except: ['new', 'edit']
  @put '/users/:id/password', 'users#password'

  @resources 'jobs', except: ['new', 'edit', 'destroy']
