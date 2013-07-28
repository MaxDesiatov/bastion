  define ['backbone', 'backbone.marionette', 'users', 'jobs', 'header'],
    (Backbone, Marionette, usersController, jobsController, headerLayout) ->
      app = new Marionette.Application()

      app.addRegions
        content: "#content"
        header: "#header"

      app.on "initialize:after", ->
        Backbone.history.start() unless Backbone.history.started
        Backbone.history.navigate 'jobs', trigger: true
        app.header.show headerLayout

      class UsersRouter extends Marionette.AppRouter
        controller: usersController
        appRoutes:
          users: 'index'

      class JobsRouter extends Marionette.AppRouter
        controller: jobsController
        appRoutes:
          jobs: 'index'

      ur = new UsersRouter
      jr = new JobsRouter
      app
