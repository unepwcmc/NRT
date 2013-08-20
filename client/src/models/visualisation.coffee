window.Backbone.Models || = {}

class window.Backbone.Models.Visualisation extends Backbone.RelationalModel
  idAttribute: '_id'

  defaults:
    type: 'BarChart'

  relations: [
      key: 'indicator'
      type: Backbone.HasOne
      relatedModel: 'Backbone.Models.Indicator'
      includeInJSON: Backbone.Models.Indicator::idAttribute
  ]

  initialize: (options={})->
    unless options.indicator?
      throw "You must initialise Visualisations with an Indicator"

  urlRoot: '/api/visualisations'

  getIndicatorData: ->
    $.get(@buildIndicatorDataUrl(), (data)=>
      @set('data', data)
      @trigger('dataFetched')
    )

  buildIndicatorDataUrl: ->
    "/api/indicators/#{@get('indicator').get('_id')}/data"

  getXAxis: ->
    @get('indicator').get('indicatorDefinition').xAxis

  getGeometryField: ->
    @get('indicator').get('indicatorDefinition').geometryField

  getHighestXRow: ->
    xAxis = @getXAxis()
    _.max(@get('data'), (row)->
      row[xAxis]
    )

  @visualisationTypes: ['BarChart', 'Map']#, 'Table']
  
#For backbone relational
Backbone.Models.Visualisation.setup()
