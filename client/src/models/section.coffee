window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  url: ->
    if @get('id')
      "/api/sections/#{@get('id')}"
    else
      '/api/sections'

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
    ,
      key: 'indicator'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Indicator'
      includeInJSON: 'id'
      reverseRelation:
        key: 'sections'
        type: Backbone.HasMany
  ]

  hasTitleOrIndicator: ->
    if @get('title')? or @get('indicator')?
      return true
    else
      return false

#For backbone relational
Backbone.Models.Section.setup()
