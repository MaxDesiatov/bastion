EditableController = Ember.ObjectController.extend
  actions:
    removeModel: ->
      model = @get 'model'
      model.deleteRecord()
      model.save()

    startEdit: ->
      @set 'isEditing', true

    stopEdit: ->
      @set 'isEditing', false

    saveChanges: ->
      @get('model').save()
      @set 'isEditing', false

  isEditing: false


`export default EditableController`
