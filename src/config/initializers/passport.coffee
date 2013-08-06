users = require '../../app/models/users'
LocalStrategy = require('passport-local').Strategy
passport = require 'passport'

module.exports = ->
  passport.use(new LocalStrategy users.verify)

  passport.serializeUser (user, done) ->
    done null, user._id

  passport.deserializeUser (token, done) ->
    users.byId token, (err, user) ->
      done err, user
