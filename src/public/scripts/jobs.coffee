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
      'click .expand': 'expand'

    ui:
      logs: '.log'

    waitingForRefresh: false

    template: (data) -> templates.item job: data

    expand: ->
      if @ui.logs.hasClass 'open'
        @ui.logs.slideUp 'fast'
      else
        @ui.logs.slideDown 'fast'
      @ui.logs.toggleClass 'open'

    onRender: ->
      if not @waitingForRefresh
        @refresh()

    refresh: ->
      if not @model.get 'finished'
        @model.fetch success: =>
          @waitingForRefresh = true
          setTimeout (=> @refresh), 500
      else
        @waitingForRefresh = false
        $('.btn.build').show()

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
      jobs.add newJob
      newJob.save()

    template: -> templates.index()

    onRender: -> @delegateEvents()

  indexLayout = new IndexLayout

  {
    "index": (fetch) ->
      jobs.fetch success: ->
        require('app').content.show indexLayout
        indexLayout.table.show jobsTable
  }
