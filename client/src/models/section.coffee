window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  default:
    title: "New Section"

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
      key: 'visualisation'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Visualisation'
      reverseRelation:
        key: 'section'
        type: Backbone.HasOne
  ]
