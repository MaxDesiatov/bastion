ProjectsController = Ember.ArrayController.extend
  actions:
    createProject: ->
      project = @store.createRecord 'project',
        name: 'Learn Ember.js'
      conf = @store.createRecord 'configuration',
        name: 'testConf'
        project: project

      project.save().then ->
        conf.save()

`export default ProjectsController`
