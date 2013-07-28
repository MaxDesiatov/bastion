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

module.exports = JobsController
