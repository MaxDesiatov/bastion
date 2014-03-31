ApplicationSerializer = DS.JSONSerializer.extend
  namespace: '/api'

  serializeHasMany: (record, json, relationship) ->
    key = relationship.key

    relationshipType =
      DS.RelationshipChange.determineRelationshipType record.constructor, relationship

    if relationshipType is 'manyToOne' or relationshipType is 'manyToMany'
      json[key] = Ember.get(record, key).mapBy('id').filter (id) -> id?

`export default ApplicationSerializer`
