express = require 'express'
poweredBy = require 'connect-powered-by'
util = require 'util'
path = require 'path'
connect = require 'connect'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
ConnectCouchDB = require('connect-couchdb') connect
users = require '../../app/models/users'

passport.use(new LocalStrategy users.verify)

passport.serializeUser (user, done) ->
  done null, user._id

passport.deserializeUser (token, done) ->
  users.byId token, (err, user) ->
    done err, user

module.exports = ->
  # Warn of version mismatch between global "lcm" binary and local installation
  # of Locomotive.
  localVersion = require('locomotive').version
  if @version isnt localVersion
    console.warn "version mismatch between local (#{localVersion}) and global" +
      "(#{@version}) Locomotive module"

  # Configure application settings.  Consult the Express API Reference for a
  # list of the available [settings](http://expressjs.com/api.html#app-settings).
  @set 'views', path.join __dirname, '../../app/views'
  @set 'view engine', 'jade'

  # Override default template extension.  By default, Locomotive finds
  # templates using the `name.format.engine` convention, for example
  # `index.html.ejs`  For some template engines, such as Jade, that find
  # layouts using a `layout.engine` notation, this results in mixed conventions
  # that can cuase confusion.  If this occurs, you can map an explicit
  # extension to a format.
  @format 'html', extension: '.jade'

  @use poweredBy 'Locomotive'
  @use express.logger()
  @use express.favicon()
  @use express.static path.join __dirname, '/../../public'
  @use express.bodyParser()
  @use express.cookieParser()
  @use express.session
    # FIXME: change this when initializing the instance
    secret: 'bastion secret'
    store: new ConnectCouchDB
      name: 'bastion-sessions'
  @use passport.initialize()
  @use passport.session()
  @use express.methodOverride()
  @use @router
