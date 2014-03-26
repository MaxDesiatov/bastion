UserController = Ember.ObjectController.extend
  actions:
    removeUser: ->
      user = @get 'model'
      user.deleteRecord()
      user.save();

`export default UserController`
