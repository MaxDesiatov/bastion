users = require '../../app/models/users'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
BitbucketStrategy = require('passport-bitbucket').Strategy

module.exports = ->
  passport.use new LocalStrategy users.verify

  passport.serializeUser (user, done) ->
    done null, user._id

  passport.deserializeUser (token, done) ->
    users.byId token, (err, user) ->
      done err, user

  passport.use new BitbucketStrategy
      #FIXME: feels ugly, isn't it?
      consumerKey: 'SET CONSUMER KEY HERE',
      consumerSecret: 'SET CONSUMER SECRET HERE',
      callbackURL: 'http://127.0.0.1:3000/auth/bitbucket/callback'
    ,
    (token, tokenSecret, profile, done) ->
      users.byName profile.username, (err, user) ->
        if err?
          done null, false
        else
          done null, user
