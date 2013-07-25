window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  url: ->
    'api/section'

  relations: [
      key: 'narrative'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Narrative'
      reverseRelation:
        key: 'section'
        type: Backbone.HasOne
    ,
      key: 'visualisations'
      type: Backbone.HasMany
      relatedModel: 'Backbone.Models.Visualisation'
      collectionType: 'Backbone.Collections.VisualisationCollection'
      reverseRelation:
        key: 'section'
  ]
