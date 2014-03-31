Job = DS.Model.extend
  configuration: DS.belongsTo 'configuration', inverse: 'jobs', async: true

`export default Job`
