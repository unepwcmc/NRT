window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  url: ->
    'api/section'

  relations: [
      key: 'narratives'
      type: Backbone.HasMany
      relatedModel: 'Backbone.Models.Narrative'
      collectionType: 'Backbone.Collections.NarrativeCollection'
      reverseRelation:
        key: 'section'
    ,
      key: 'visualisations'
      type: Backbone.HasMany
      relatedModel: 'Backbone.Models.Visualisation'
      collectionType: 'Backbone.Collections.VisualisationCollection'
      reverseRelation:
        key: 'section'
  ]
