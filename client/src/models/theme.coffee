window.Backbone.Models || = {}

class window.Backbone.Models.Theme extends Backbone.RelationalModel
  idAttribute: '_id'

  urlRoot: '/api/themes'

  relations: [
    key: 'sections'
    type: Backbone.HasMany
    relatedModel: 'Backbone.Models.Section'
    collectionType: 'Backbone.Collections.SectionCollection'
    reverseRelation:
      key: 'parent'
      includeInJSON: false
  ]


#For backbone relational
Backbone.Models.Theme.setup()
