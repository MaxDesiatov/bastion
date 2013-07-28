define [
  'backbone',
  'backbone.marionette',
  'jquery',
  '../views/jobs'], (Backbone, Marionette, $, templates) ->

  Job = Backbone.Model.extend
    idAttribute: "_id"
    defaults:
      finished: false
      failed: false
      addedTime: null

  Jobs = Backbone.Collection.extend
    model: Job
    url: '/jobs'

  class UserView extends Marionette.ItemView
    modelEvents:
      'change': 'render'

    events:
      'click li.job': 'expand'

    ui:
      logs: '.job_container'

    expand: ->
      if @ui.logs.hasClass 'open'
        @ui.logs.slideUp 'fast'
      else
        @ui.logs.slideDown 'fast'
      @ui.logs.toggleClass 'open'

  updateJob = (job) ->
      id = $(job).find('.job_id').first().html()
      $.get "/job/#{id}", (data) ->
          $(job).find('.job_container').first().html(data.log)
          if data.finished
              $(job).find('a img.loader').remove()
              $(job).find('a').first().append CoffeeKup.render outcomeTemplate, job: data
              $('button.build').show()
              return false
          setTimeout ->
              updateJob job
          , 1000
      , 'json'

  $('button.build').click (event) ->
      closeAll()
      $('button.build').hide()
      $('li.nojob').hide()
      $.post '/', (data) ->
          if $('ul.jobs').find('li.nojob').length > 0
             $('ul.jobs').find('li.nojob').first().remove()
          job = $('ul.jobs').prepend CoffeeKup.render jobTemplate, job: data
          job = $(job).find('li').first()
          addClick job
          updateJob job
          $(job).find('.job_container').click()
      , 'json'
      return false

  $('li.job').each (iterator, job)->
      addClick job
