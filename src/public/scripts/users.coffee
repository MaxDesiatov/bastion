define [
  'backbone',
  'backbone.marionette',
  'jquery',
  '../views/users',
  'require',
  'app',
  'bootstrap'], (Backbone, Marionette, $, templates, require, app) ->

  User = Backbone.Model.extend
    idAttribute: "_id"
    defaults:
      firstName: ''
      lastName: ''
      group: 'guest'
      name: ''

  Users = Backbone.Collection.extend
    model: User
    url: '/users'

  modal = $('#user-remove-modal')

  class UserView extends Marionette.ItemView
    isEditing: false
    tagName: 'tr'
    className: 'user-row'

    modelEvents:
      'change': 'render'

    events:
      'click .change-password-button': 'changePassword'
      'click .user-edit-button': 'edit'
      'click .user-remove-button': 'removeSelf'
      'click .user-save-button': 'save'

    # workaround for template not bind before invocation by marionette.js
    constructor: ->
      @template = _.bind(@template, @)
      args = Array.prototype.slice.apply arguments
      Marionette.ItemView.prototype.constructor.apply this, args

    template: (data) ->
      t = if @model.isNew() or @isEditing then templates.edit else templates.item
      t
        user: data
        cid: data.cid

    edit: ->
      @isEditing = true
      @render()

    onRender: ->
      if @isEditing
        $('.role-help').popover
          content: templates.help()
          html: true
          trigger: 'hover'

    removeSelf: ->
      if not @model.isNew()
        modal.html templates.modal name: @model.get 'name'
        modal.find('.btn-primary').click =>
          @model.destroy()
          modal.modal 'hide'
        modal.modal 'show'
      else
        users.remove @model

    save: ->
      changes = {}
      _(['name', 'firstName', 'lastName', 'group']).each (prop) ->
        changes[prop] = $(@$el).find("[name=#{prop}]").val()
      if changes.name.length < 1
        $('.notifications').notify(
          message: text: 'Empty username'
          type: 'blackgloss').show()
        return
      sameName = users.findWhere name: changes.name
      if sameName? and sameName.cid isnt userid
        $('.notifications').notify(
          message: text: 'User with same name already exists'
          type: 'blackgloss').show()
      else
        @isEditing = false
        @model.save changes

    changePassword: ->
      @$el.html templates.password()
      errorMessage = $(@$el).find('.text-error')
      errorMessageDisplayed = false
      $(@$el).find('input[type=password]').keypress ->
        if errorMessageDisplayed
          errorMessage.removeClass 'in'
          errorMessageDisplayed = false
      $(@$el).find('.cancel-password-button').click =>
        @render()
        workspace.navigate 'index'
      $(@$el).find('.save-password-button').click =>
        password = $(@$el).find('[name=password]').val()
        repeat = $(@$el).find('[name=repeat]').val()
        if password isnt repeat
          errorMessage.text "Passwords aren't equal!"
          errorMessageDisplayed = true
          errorMessage.addClass 'in'
        else if password.length < 1
          errorMessage.text 'Password not entered'
          errorMessageDisplayed = true
          errorMessage.addClass 'in'
        else
          $.ajax
            url: "#{@model.url()}/password"
            data: JSON.stringify password: password
            cache: false,
            contentType: 'application/json'
            processData: false
            type: 'PUT'
            success: () =>
              @render()
              workspace.navigate 'index'
            error: () ->
              errorMessage.text 'Error while changing password'
              errorMessageDisplayed = true
              errorMessage.addClass 'in'

  users = new Users

  class UsersTable extends Marionette.CompositeView
    collection: users
    itemView: UserView

    template: -> templates.table()

    appendHtml: (collectionView, itemView, index) ->
      childrenContainer = $(collectionView.childrenContainer or collectionView.el)
      children = childrenContainer.children()
      if children.size() is index
        childrenContainer.append itemView.el
      else
        childrenContainer.children().eq(index).after itemView.el

  usersTable = new UsersTable

  class IndexLayout extends Marionette.Layout
    regions:
      table: '#user-table'

    events:
      'click #user-new': 'create'

    create: ->
      users.add new User
      users

    template: -> templates.index()

  indexLayout = new IndexLayout

  {
    "index": (fetch) ->
      users.fetch success: ->
        require('app').content.show indexLayout
        indexLayout.table.show usersTable
  }
