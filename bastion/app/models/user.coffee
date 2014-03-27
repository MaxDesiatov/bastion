User = DS.Model.extend
  name: DS.attr 'string'
  firstName: DS.attr 'string'
  lastName: DS.attr 'string'
  group: DS.attr 'string'

# User.FIXTURES = [
#   {
#     id: 1
#     name: 'Learn Ember.js'
#     firstName: 'x'
#     lastName: 'y'
#     group: 'kjlnsdlkv'
#   }
#   {
#     id: 2
#     name: '...'
#     firstName: 'x'
#     lastName: 'y'
#     group: 'kjlnsdlkv'
#   }
#   {
#     id: 3
#     name: 'Profit!'
#     firstName: 'x'
#     lastName: 'y'
#     group: 'kjlnsdlkv'
#   }
#   {
#     id: 4
#     name: 'blah'
#     firstName: 'x'
#     lastName: 'y'
#     group: 'kjlnsdlkv'
#   }
# ]

`export default User`
