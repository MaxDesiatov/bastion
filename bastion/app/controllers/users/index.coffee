UsersController = Ember.ArrayController.extend
  actions:
    createUser: ->
      user = @store.createRecord 'user',
        name: 'Learn Ember.js'
        firstName: 'x'
        lastName: 'y'
        group: 'kjlnsdlkv'
        isCompleted: true

      user.save()

  columns: Ember.computed ->
    [Ember.Table.ColumnDefinition.create
      columnWidth: 100
      headerCellName: 'Name'
      getCellContent: (row) -> row.get 'name'
    Ember.Table.ColumnDefinition.create
      columnWidth: 100
      headerCellName: 'First Name'
      getCellContent: (row) -> row.get 'firstName'
    Ember.Table.ColumnDefinition.create
      columnWidth: 100
      headerCellName: 'Last Name'
      getCellContent: (row) -> row.get 'lastName'
    Ember.Table.ColumnDefinition.create
      columnWidth: 100
      headerCellName: 'Group'
      getCellContent: (row) -> row.get 'group'
    ]

`export default UsersController`
