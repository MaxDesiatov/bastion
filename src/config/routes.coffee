passport = require 'passport'

module.exports = ->
  @root 'pages#main'
  @get '/login', 'pages#login'
  @get '/logout', 'pages#logout'

  @post '/auth/local', passport.authenticate 'local',
    successRedirect: '/'
    failureRedirect: '/login'

  @get '/auth/bitbucket', passport.authenticate 'bitbucket'
  @get '/auth/bitbucket/callback', passport.authenticate 'bitbucket',
    successRedirect: '/'
    failureRedirect: '/login'

  @get '/users/current', 'users#current'
  @resources 'users', except: ['new', 'edit']
  @put '/users/:id/password', 'users#password'

  @resources 'jobs', except: ['new', 'edit', 'destroy']
