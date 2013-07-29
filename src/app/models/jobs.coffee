db = require 'benchdb/api'
Type = require 'benchdb'
path = require 'path'
dbName = path.basename(process.cwd()).replace(/\./, "-")
_ = require 'underscore'
a = require 'async'

bastionDb = new db '127.0.0.1', 5984, 'bastion'

jobType = new Type bastionDb, 'job'

jobs = module.exports =
  current: null
  addJob: (next) ->
    jobType.instance true, (error, instance) ->
      _(instance.data).extend
        addedTime: new Date().getTime()
        log: {}
        running: false
        finished: false
      instance.save ->
        next(instance.data)

  getQueued: (next) ->
    getJobs running: false, next

  getRunning: (next) ->
    getJobs running: true, next

  getAll: (cb) ->
    jobType.filterByFields include_docs: true, sort: ['addedTime'], descending: true,
      (err, res) -> cb (job.data for job in res.instances)

  getLast: (next) ->
    jobType.filterByField
      sort: 'addedTime'
      descending: true
      limit: 1
      include_docs: true, (error, res) ->
        collection = res.instances
        if collection.length > 0
          next collection[0].data
        else
          next()

  get: (id, next) ->
    bastionDb.retrieve id, (error, job) ->
      if error?
        next "No job found with the id '#{id}'"
      else
        next job

  clear: (cb) ->
    jobType.all (err, res) ->
      a.each res.instances, ((one, next) -> bastionDb.remove one.data, next), ->
        cb res.instances

  getLog: (id, next) ->
    bastionDb.retrieve id, (error, job) ->
      if error?
        next "No job found with the id '#{id}'"
      else
        next job.log

  byId: (id, cb) ->
    a.waterfall [
      _(bastionDb.checkExists).bind(bastionDb),
      _.chain(bastionDb.retrieve).partial(id).bind(bastionDb).value()], cb

  modifyOrCreate: (newData, cb) ->
    if newData._id
      @byId newData._id, (err, oldData) ->
        if err is 'not_found'
          bastionDb.create newData, cb
        else if err?
          cb err, {}
        else
          _(oldData).extend newData
          bastionDb.modify oldData, cb
    else
      jobType.instance true, (err, instance) ->
        if err?
          cb err, {}
        else
          _(instance.data).extend(newData)
          instance.save cb

  updateLog: (id, obj, next) ->
    bastionDb.retrieve id, (error, job) ->
      if error?
        return false
      else
        if not _.isObject job.log
          job.log = {}
        for k, v of obj
          if not _.isObject job.log[k]
            job.log[k] = {}
          _(job.log[k]).extend v
        bastionDb.modify job, (err, res) ->
          next()

  currentComplete: (success, next) ->
    bastionDb.retrieve @current, (error, job) ->
      if error?
        return false
      else
        job.running = false
        job.finished = true
        job.failed = not success
        job.finishedTime = new Date().getTime()
        jobs.current = null
        bastionDb.modify job, ->
          next()

  next: (next) ->
    jobType.filterByFields {sort: ['addedTime'], limit: 1},
      {running: no, finished: no}, (error, res) ->
        job = res.instances[0]
        return false if not job?
        job.data.running = true
        job.data.startedTime = new Date().getTime()
        jobs.current = job.id
        job.save -> next()

getJobs = (filter, next) ->
  if filter?
    jobType.filterByFields {sort: ['addedTime'], include_docs: true}, filter,
      (error, res) ->
        next (job.data for job in res.instances)
  else
    jobType.filterByFields {sort: ['addedTime'], include_docs: true},
      (error, res) ->
        next (job.data for job in res.instances)
