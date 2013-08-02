define [
  'backbone',
  'backbone.marionette',
  '../views/header'], (Backbone, Marionette, templates) ->

  currentUser = new (Backbone.Model.extend
    idAttribute: '_id'
    url: -> '/users/current')

  class HeaderView extends Marionette.ItemView
    model: currentUser
    currentlyActive: null
    ui:
      jobs: '#jobs-navigation'
      users: '#users-navigation'

    events:
      'click p a.btn': 'changePassword'

    className: 'container'

    # workaround for template not bind before invocation by marionette.js
    constructor: ->
      @template = _.bind(@template, @)
      args = Array.prototype.slice.apply arguments
      Marionette.ItemView.prototype.constructor.apply this, args

    template: ->
      templates.header
        # user: data
        user:
          name: 'test-user'
          group: 'admin'
        active: @currentlyActive

    changePassword: ->
      $('#change-password-modal').modal 'show'

    onRender: ->
      modal = $ '#change-password-modal'
      password = $ '#change-password-one'
      repeat = $ '#change-password-two'
      repeatGroup = modal.find '.control-group:last-child'
      repeatGroup.find('input').keypress ->
        repeatGroup.removeClass 'error'
      modal.find('.btn-primary').click =>
        if repeat.val() isnt password.val()
          repeatGroup.addClass 'error'
        else
          $.ajax
            url: "/users/api/#{@model.id}/password"
            data: JSON.stringify password: password.val()
            cache: false
            contentType: 'application/json'
            processData: false
            type: 'PUT'
            error: ->
              indexLayout.notify 'Error while changing password'
          modal.modal 'hide'

    onRoute: (route) ->
      if route isnt @currentlyActive and @ui[@currentlyActive]?
        if @currentlyActive?
          @ui[@currentlyActive].removeClass 'active'
        @ui[route].addClass 'active'
      @currentlyActive = route

  headerView = null
  Backbone.history.on 'route', ->
    headerView.onRoute Backbone.history.fragment

  headerView = new HeaderView
