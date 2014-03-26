User = DS.Model.extend
  name: DS.attr 'string'
  firstName: DS.attr 'string'
  lastName: DS.attr 'string'
  group: DS.attr 'string'
  isCompleted: DS.attr 'boolean'

User.FIXTURES = [
  {
    id: 1
    name: 'Learn Ember.js'
    firstName: 'x'
    lastName: 'y'
    group: 'kjlnsdlkv'
    isCompleted: true
  }
  {
    id: 2
    name: '...'
    firstName: 'x'
    lastName: 'y'
    group: 'kjlnsdlkv'
    isCompleted: false
  }
  {
    id: 3
    name: 'Profit!'
    firstName: 'x'
    lastName: 'y'
    group: 'kjlnsdlkv'
    isCompleted: false
  }
  {
    id: 4
    name: 'blah'
    firstName: 'x'
    lastName: 'y'
    group: 'kjlnsdlkv'
    isCompleted: true
  }
]

`export default User`
