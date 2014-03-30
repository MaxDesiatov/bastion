Configuration = DS.Model.extend
  name: DS.attr 'string'
  script: DS.attr 'string'
  project: DS.belongsTo 'project', inverse: 'configurations', async: true

`export default Configuration`
