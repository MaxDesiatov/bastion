db = require 'benchdb/api'
Type = require 'benchdb'
a = require 'async'
_ = require 'underscore'
bcrypt = require 'bcrypt'

updatesDb = new db '127.0.0.1', 5984, 'bastion'
userType = new Type updatesDb, 'user'

userType.oneByName = (username, endCb) ->
  a.waterfall [
    _(@api.checkExists).bind(updatesDb),
    _.chain(@filterByField).bind(@).partial(include_docs: true, 'name', username).value(),
    ((res, cb) -> cb null, res.instances)], endCb

module.exports =
  verify: (username, password, done) ->
    userType.oneByName username, (err, users) ->
      if err?
        done err
      else if users.length < 1
        done null, false, message: 'Incorrect username.'
      else if users[0].data.password and users[0].data.password.length > 0
        userData = users[0].data
        bcrypt.compare password, userData.password, (err, ok) ->
          if err?
            done err, false, message: 'Error while verifying password'
          else if ok
            done null, userData
          else
            done null, false, message: 'Incorrect password.'
      else
        done null, false,
          message: 'Attempt to login as a user with unitialized password'

  byName: (name, cb) ->
    userType.oneByName name, (err, users) ->
      if err?
        cb err, {}
      else if users.length < 1
        cb 'no users found', {}
      else
        cb null, users[0].data

  byId: (id, cb) ->
    a.waterfall [
      _(updatesDb.checkExists).bind(updatesDb),
      _.chain(updatesDb.retrieve).partial(id).bind(updatesDb).value()], cb

  all: (endCb) ->
    a.waterfall [
      _(updatesDb.checkExists).bind(updatesDb),
      ((cb) ->
        userType.filterByField include_docs: true, (err, res) ->
          if err?
            endCb err, []
          else
            cb null, res.instances)], endCb

  modifyOrCreate: (userData, cb) ->
    if userData._id
      @byId userData._id, (err, oldData) ->
        if err is 'not_found'
          updatesDb.create userData, cb
        else if err?
          cb err, {}
        else
          _(oldData).extend userData
          updatesDb.modify oldData, cb
    else
      userType.instance true, (err, instance) ->
        if err?
          cb err, {}
        else
          _(instance.data).extend(userData)
          instance.save (err, res) ->
            if err?
              cb err, {}
            else
              cb null, _(res).extend instance.data

  setPassword: (id, password, cb) ->
    bcrypt.hash password, 10, (err, hash) =>
      if err?
        cb err, {}
      else
        @modifyOrCreate password: hash, _id: id, cb

  remove: (id, cb) ->
    updatesDb.retrieve id, (err, res) ->
      if err?
        cb err, res
      else
        updatesDb.remove res, cb
