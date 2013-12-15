define [
  'backbone',
  'backbone.marionette',
  'jquery',
  'underscore',
  '../views/jobs',
  'moment'], (Backbone, Marionette, $, _, templates, moment) ->

  class Job extends Backbone.Model
    idAttribute: "_id"
    defaults:
      finished: false
      failed: false
      addedTime: null

  class Jobs extends Backbone.Collection
    model: Job
    url: '/jobs'

  class JobView extends Marionette.ItemView
    # workaround for template not bind before invocation by marionette.js
    constructor: ->
      @template = _.bind(@template, @)
      args = Array.prototype.slice.apply arguments
      Marionette.ItemView.prototype.constructor.apply this, args

    tagName: 'li'
    className: 'job'
    modelEvents:
      'change': 'render'

    events:
      'click .description': 'expand'
      'click .job-cancel': 'cancel'

    ui:
      logs: '.log'
      spinner: '.spinner-icon'
      timeDiff: '.time-diff'

    waitingForRefresh: false
    degree: 0

    timeDiff: ->
      addedTime = @model.get 'addedTime'
      finishedTime = @model.get 'finishedTime'
      finished = @model.get 'finished'
      if addedTime
        t =
          if finished and finishedTime
            finishedTime
          else
            new Date().getTime()
        result = t - addedTime
      else
        result = 0

      if result is 1
        "1 millisecond"
      else if result < 1000
        "#{result} milliseconds"
      else
        seconds = Math.floor(result / 1000)
        resultString = ""
        converter =
          day: (x) -> (x % 31536000) / 86400
          hour: (x) -> ((x % 31536000) % 86400) / 3600
          minute: (x) -> (((x % 31536000) % 86400) % 3600) / 60
          second: (x) -> (((x % 31536000) % 86400) % 3600) % 60
        for unit, f of converter
          converted = Math.floor f seconds
          if converted is 1
            resultString += "1 #{unit} "
          else if converted > 0
            resultString += "#{converted} #{unit}s "
        resultString

    template: (data) ->
      log = []
      for type, items of data.log
        for date, item of items
          log.push date: date, content: item, type: type

      started = if data.addedTime then moment data.addedTime else moment()
      templates.item
        job: data
        log: log.sort (a, b) -> a.date - b.date
        started: started.calendar()
        timeDiff: @timeDiff()

    expand: ->
      if @ui.logs.hasClass 'open'
        @ui.logs.slideUp 'fast'
      else
        @ui.logs.slideDown 'fast'
      @ui.logs.toggleClass 'open'

    cancel: ->
      @model.save finished: true, finishedTime: new Date().getTime()

    onRender: ->
      if not @waitingForRefresh
        @refresh()
        @rotate()
      if @model.get('finished') is true
        $('#job-new').show()

    rotate: ->
      if @waitingForRefresh and @ui.spinner.css?
        @degree = if @degree is 360 then 45 else @degree + 45
        rotateString = "rotate(#{@degree}deg)"
        for transform in ['WebkitTransform', '-moz-transform']
          css = {}
          css[transform] = rotateString
          @ui.spinner.css css
        setTimeout (=> @rotate()), 100

    refresh: ->
      if not @model.get 'finished'
        @bindUIElements()
        @ui.timeDiff.text @timeDiff()
        @waitingForRefresh = true
        @model.fetch success: =>
          setTimeout (=> @refresh()), 1000
      else
        @waitingForRefresh = false

  jobs = new Jobs

  class Empty extends Marionette.ItemView
    tagName: 'li'
    className: 'nojobs'
    template: -> 'No jobs have been submitted.'

  class JobsTable extends Marionette.CollectionView
    tagName: 'ul'
    className: 'jobs'
    itemView: JobView
    emptyView: Empty
    collection: jobs
    collectionEvents:
      change: 'render'

    appendHtml: (collectionView, itemView, index) ->
      childrenContainer = $(collectionView.childrenContainer or collectionView.el)
      children = childrenContainer.children()
      if children.size() is index
        childrenContainer.append itemView.el
      else
        childrenContainer.children().eq(index).before itemView.el

    onRender: -> @delegateEvents()

  jobsTable = new JobsTable

  class IndexLayout extends Marionette.Layout
    regions:
      table: '#jobs-table'

    ui:
      buildButton: '#job-new'

    events:
      'click #job-new': 'build'

    build: ->
      @ui.buildButton.hide()
      newJob = new Job
      jobs.add newJob, at: 0
      newJob.save {},
        error: => @ui.buildButton.show()

    template: -> templates.index()

    onRender: -> @delegateEvents()

  indexLayout = new IndexLayout

  {
    index: (fetch) ->
      jobs.fetch success: ->
        require('app').content.show indexLayout
        indexLayout.table.show jobsTable
  }
