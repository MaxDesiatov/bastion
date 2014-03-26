IndexRoute = Ember.Route.extend
  model: -> this.store.find('user')

`export default IndexRoute`
