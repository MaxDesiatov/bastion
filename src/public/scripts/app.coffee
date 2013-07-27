  define ['backbone', 'backbone.marionette', 'users', 'header'],
    (Backbone, Marionette, usersController, headerLayout) ->
      app = new Marionette.Application()

      app.addRegions
        content: "#content"
        header: "#header"

      app.on "initialize:after", ->
        Backbone.history.start() unless Backbone.history.started
        Backbone.history.navigate 'users', trigger: true
        app.header.show headerLayout

      class UsersRouter extends Marionette.AppRouter
        controller: usersController
        appRoutes:
          users: 'index'

      ur = new UsersRouter
      app
