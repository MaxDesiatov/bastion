ProjectsController = Ember.ArrayController.extend
  actions:
    createProject: ->
      project = @store.createRecord 'project',
        name: 'Learn Ember.js'

      project.save()

`export default ProjectsController`
