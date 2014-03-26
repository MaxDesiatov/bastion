UserController = Ember.ObjectController.extend
  actions:
    removeUser: ->
      user = @get 'model'
      user.deleteRecord()
      user.save()

    startEdit: ->
      @set 'isEditing', true

    stopEdit: ->
      @set 'isEditing', false

    saveChanges: ->
      @get('model').save()
      @set 'isEditing', false

  isEditing: false

`export default UserController`
