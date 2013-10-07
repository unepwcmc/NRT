window.Backbone.Models || = {}

class window.Backbone.Models.Section extends Backbone.RelationalModel
  urlRoot: '/api/sections'

  idAttribute: '_id'

  defaults:
    type: 'Section'

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
        includeInJSON: @::idAttribute
        type: Backbone.HasOne
    ,
      key: 'indicator'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Indicator'
      includeInJSON: '_id'
  ]

  hasTitleOrIndicator: ->
    if @get('title')? or @get('indicator')?
      return true
    else
      return false

  # Don't save the section itself, save the whole report
  save: (attributes, options) ->
    if arguments.length == 1
      options = attributes
      attributes = {}

    if @get('page')?
      @get('page').save(section: attributes, options)
    else
      throw "You're trying to save a section without a parent page, this shouldn't happen"

#For backbone relational
Backbone.Models.Section.setup()
