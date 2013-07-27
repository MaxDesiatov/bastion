  define ['backbone', 'backbone.marionette', 'users'],
    (Backbone, Marionette, usersController) ->
      app = new Marionette.Application()

      app.addRegions
        content: "#content"
        header: "#menu"

      app.on "initialize:after", ->
        Backbone.history.start() unless Backbone.history.started
        Backbone.history.navigate 'users', trigger: true

      class UsersRouter extends Marionette.AppRouter
        controller: usersController
        appRoutes:
          users: 'index'

      ur = new UsersRouter
      app
