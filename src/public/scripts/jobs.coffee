define [
  'backbone',
  'backbone.marionette',
  'jquery',
  'underscore',
  '../views/jobs'], (Backbone, Marionette, $, _, templates) ->

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

    waitingForRefresh: false
    degree: 0

    template: (data) ->
      log = []
      for type, items of data.log
        for date, item of items
          log.push date: date, content: item, type: type
      templates.item job: data, log: log.sort (a, b) -> a.date - b.date

    expand: ->
      if @ui.logs.hasClass 'open'
        @ui.logs.slideUp 'fast'
      else
        @ui.logs.slideDown 'fast'
      @ui.logs.toggleClass 'open'

    cancel: ->
      @model.save finished: true

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
