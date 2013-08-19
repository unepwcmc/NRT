window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  urlRoot: '/api/sections'

  idAttribute: '_id'

  relations: [
      key: 'narrative'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Narrative'
      includeInJSON: false
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

  # Don't save the section itself, save the whole report
  save: (attributes, options) ->
    if @get('report')?
      @get('report').save(section: attributes, options)
    else
      throw "You're trying to save a section without a parent report, this shouldn't happen"

#For backbone relational
Backbone.Models.Section.setup()
