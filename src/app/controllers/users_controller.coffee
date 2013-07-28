locomotive = require 'locomotive'
users = require '../models/users'
_ = require 'underscore'

UsersController = new locomotive.Controller()

_(UsersController).extend
  index: ->
    users.all (err, all) =>
      if err?
        @res.send 500, err
      else
        @res.send(for one in all
          delete one.data.password
          one.data)

  current: ->
    if _.isObject @req.user
      responseObject = _.clone(req.user)
      delete responseObject.password
      @res.send responseObject
    else
      @res.send 403

  create: -> @update()

  update: ->
    users.modifyOrCreate @req.body, (err, modifyResponse) =>
      if err?
        @res.send 500, err
      else
        responseObject = _.clone(@req.body)
        responseObject._id = modifyResponse.id
        @res.send 200, responseObject

  destroy: ->
    if @param('id')
      users.remove @param('id'), (err) =>
        if err?
          @res.send 500, err
        else
          @res.send 200
    else
      @res.send 500, 'wrong method parameters'

  password: ->
    if @req.body and @req.body.password and _.isString(@req.body.password) and
    @req.body.password.length > 0 and @req.params and @req.params.userid and
    _.isString(@req.params.userid) and @req.params.userid.length > 0
      users.setPassword @req.params.userid, @req.body.password, (err) =>
        if err?
          @res.send 500, err
        else
          @res.send 200
    else
      @res.send 500, 'wrong method parameters'

module.exports = UsersController
