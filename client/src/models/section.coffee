window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  defaults:
    visualisations: []
    narratives: new Backbone.Collections.NarrativeCollection

  relations: [
    key: 'narratives'
    type: Backbone.HasMany
    relatedModel: 'Backbone.Models.Narrative'
    collectionType: 'Backbone.Collections.NarrativeCollection'
    reverseRelation:
      key: 'section'
  ]
