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

  class NavigationView extends Marionette.ItemView
    className: "nav"
    tagName: "ul"
    model: currentUser
    template: (data) ->
      templates.navigation
        # user: data
        user: group: 'admin'

  class HeaderLayout extends Marionette.Layout
    regions:
      currentUser: '#header-current-user'
      navigation: '#header-navigation'
      search: '#header-search'

    template: ->
      templates.header()

    onRender: ->
      @currentUser.show new CurrentUserView
      @navigation.show new NavigationView

  new HeaderLayout
