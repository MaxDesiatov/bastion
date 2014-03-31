Project = DS.Model.extend
  name: DS.attr 'string'
  sourceURL: DS.attr 'string'
  configurations: DS.hasMany 'configuration', inverse: 'project', async: true

`export default Project`
