locomotive = require 'locomotive'
jobs = require '../models/jobs'
_ = require 'underscore'
runner = require '../jobs/runner'

JobsController = new locomotive.Controller()

_(JobsController).extend
  index: ->
    jobs.getAll (all) => @res.send all

  show: ->
    jobs.get @params('id'), (job) => @res.send job

  create: ->
    jobs.addJob (job) =>
      runner.build()
      @res.send job

  update: ->
    jobs.modifyOrCreate @req.body, (err, modifyResponse) =>
      if err?
        @res.send 500, err
      else
        responseObject = _.clone(@req.body)
        responseObject._id = modifyResponse.id
        @res.send 200, responseObject

module.exports = JobsController
