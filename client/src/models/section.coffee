window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  url: ->
    if @get('id')
      "/api/section/#{@get('id')}"
    else
      '/api/section'

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

  hasTitleOrIndicator: ->
    if @get('title')
      return true
    else
      return false
