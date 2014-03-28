Router = Ember.Router.extend()

Router.reopen
  location: 'history'

Router.map ->
  @resource 'projects', path: '/', ->
  @resource 'users', path: '/users', ->

`export default Router`
