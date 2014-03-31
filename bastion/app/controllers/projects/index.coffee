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
      .then ->
        project.get('configurations')
      .then (confs) ->
        confs.pushObject conf
        project.save()

`export default ProjectsController`
