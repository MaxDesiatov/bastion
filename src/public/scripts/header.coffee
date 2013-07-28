define [
  'backbone',
  'backbone.marionette',
  '../views/header'], (Backbone, Marionette, templates) ->

  currentUser = new (Backbone.Model.extend
    idAttribute: "_id"
    url: -> '/users/current')

  class CurrentUserView extends Marionette.ItemView
    className: "nav pull-right"
    tagName: "ul"
    model: currentUser

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
            error: =>
              indexLayout.notify 'Error while changing password'
          modal.modal 'hide'

    events:
      'click p a.btn': 'changePassword'

    changePassword: ->
      $('#change-password-modal').modal 'show'

    template: (data) ->
      templates.currentUser
        # user: data
        user: name: 'test-user'

  cuView = new CurrentUserView

  class NavigationView extends Marionette.ItemView
    className: "nav"
    tagName: "ul"
    model: currentUser
    currentlyActive: null
    ui:
      jobs: '#jobs-navigation'
      users: '#users-navigation'

    # workaround for template not bind before invocation by marionette.js
    constructor: ->
      @template = _.bind(@template, @)
      args = Array.prototype.slice.apply arguments
      Marionette.ItemView.prototype.constructor.apply this, args

    template: (data) ->
      templates.navigation
        # user: data
        user:
          group: 'admin'
        active: @currentlyActive

    onRoute: (route) ->
      if route isnt @currentlyActive and @ui[@currentlyActive]?
        if @currentlyActive?
          @ui[@currentlyActive].removeClass 'active'
        @ui[route].addClass 'active'
      @currentlyActive = route

  navigationView = new NavigationView

  Backbone.history.on 'route', ->
    navigationView.onRoute Backbone.history.fragment

  class HeaderLayout extends Marionette.Layout
    regions:
      currentUser: '#header-current-user'
      navigation: '#header-navigation'
      search: '#header-search'

    template: ->
      templates.header()

    onRender: ->
      @currentUser.show cuView
      @navigation.show navigationView

  new HeaderLayout
