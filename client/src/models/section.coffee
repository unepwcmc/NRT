window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  urlRoot: '/api/sections'

  idAttribute: '_id'

  relations: [
      key: 'narrative'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Narrative'
      reverseRelation:
        key: 'section'
        includeInJSON: '_id'
        type: Backbone.HasOne
    ,
      key: 'visualisation'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Visualisation'
      includeInJSON: false
      reverseRelation:
        key: 'section'
        includeInJSON: '_id'
        type: Backbone.HasOne
    ,
      key: 'indicator'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Indicator'
      includeInJSON: '_id'
      reverseRelation:
        key: 'sections'
        includeInJSON: false
        type: Backbone.HasMany
  ]

  hasTitleOrIndicator: ->
    if @get('title')? or @get('indicator')?
      return true
    else
      return false

#For backbone relational
Backbone.Models.Section.setup()
