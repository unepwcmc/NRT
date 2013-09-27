window.Backbone.Models || = {}

class window.Backbone.Models.Page extends Backbone.RelationalModel
  relations: [
    key: 'sections'
    type: Backbone.HasMany
    relatedModel: 'Backbone.Models.Section'
    collectionType: 'Backbone.Collections.SectionCollection'
    reverseRelation:
      key: 'page'
      includeInJSON: false
  ]

Backbone.Models.Page.setup()
