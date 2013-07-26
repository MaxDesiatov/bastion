define ["backbone", "jquery"], (Backbone, $) ->
  User = Backbone.Model.extend
    idAttribute: "_id"
    defaults:
      firstName: ''
      lastName: ''
      group: 'guest'
      name: ''

  Users = Backbone.Collection.extend
    model: User
    url: "/users/api"

  UserView = Backbone.View.extend
    tagName: "tr",

    className: "user-row",

    initialize: ->
      @listenTo @model, "change", @render

    render: ->
      @$el.html jade.render 'users.model',
        user: @model.attributes
        cid: @model.cid

    edit: ->
      @$el.html jade.render 'users.model.edit',
        user: @model.attributes
        cid: @model.cid

      $(@$el).find('.change-password-button').click =>
        @changePassword()

    changePassword: ->
      @$el.html jade.render 'users.model.password',
        user: @model.attributes
        cid: @model.cid
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

  indexRefresh = (c) ->
    c.each (u) ->
      u.view = new UserView model: u
      u.view.render()
      $('#user-table').append u.view.el

  Workspace = Backbone.Router.extend
    routes:
      "index": (fetch) ->
        $('#user-index').html jade.render 'users.index'
        m = $('#remove-modal')
        m.modal show: false
        m.on 'hidden', -> workspace.navigate 'index'
        $('#remove-modal .btn-primary').click ->
          m.modal 'hide'
        if _.isBoolean fetch and fetch
          users.fetch
            success: indexRefresh
        else
          indexRefresh users

      "edit/:userid": (userid) ->
        if Backbone.history.fragment isnt 'index'
          @routes.index
        users.get(userid).view.edit()

      "remove/:userid(/:confirm)": (userid, confirm) ->
        u = users.get(userid)
        if not u.isNew() and not confirm
          $('#remove-modal .btn-primary').attr 'href', "#remove/#{userid}/yes"
          $('#remove-modal .modal-body p').text "Are you sure you want " +
            "to remove user \"#{u.get 'name'}\"?"
          $('#remove-modal').modal 'show'
        else
          if not u.isNew()
            u.destroy()
          u.view.remove()
          workspace.navigate 'index'

      "save/:userid": (userid) ->
        u = users.get userid
        changes = {}
        _(['name', 'firstName', 'lastName', 'group']).each (prop) ->
          changes[prop] = $(u.view.$el).find("[name=#{prop}]").val()
        if changes.name.length < 1
          $('.notifications').notify(
            message: text: 'Empty username'
            type: 'blackgloss').show()
          workspace.navigate "edit/#{userid}"
          return
        sameName = users.findWhere name: changes.name
        if sameName? and sameName.cid isnt userid
          $('.notifications').notify(
            message: text: 'User with same name already exists'
            type: 'blackgloss').show()
          workspace.navigate "edit/#{userid}"
        else
          u.save changes
          u.view.render()
          workspace.navigate 'index'

      "new": ->
        if Backbone.history.fragment isnt 'index'
          @routes.index
        u = new User
        users.add u
        u.view = new UserView model: u
        u.view.edit()
        $('#user-table tr:first-child').after u.view.el

  console.log "users module loaded"
  x: 5
  # Backbone.history.start()
  # workspace = new Workspace
  # workspace.routes.index true
