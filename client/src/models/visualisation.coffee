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

  getIndicatorData: (callback)->
    if @get('data')?
      callback(null, @get('data'))
    else
      $.get(@buildIndicatorDataUrl()).done((data)=>
        @set('data', data)
        callback(null, data)
      ).fail((jqXHR, textStatus, errorThrown)->
        callback(
          message: "Error fetching indicator data"
          errors: [textStatus, errorThrown]
        )
      )

  buildIndicatorDataUrl: ->
    "/api/indicators/#{@get('indicator').get('_id')}/data"

  getXAxis: ->
    @get('indicator').get('indicatorDefinition').xAxis

  getYAxis: ->
    @get('indicator').get('indicatorDefinition').yAxis

  getGeometryField: ->
    @get('indicator').get('indicatorDefinition').geometryField

  getHighestXRow: ->
    xAxis = @getXAxis()
    _.max(@get('data').results, (row)->
      row[xAxis]
    )

  mapDataToXAndY: ->
    xAxis = @getXAxis()
    yAxis = @getYAxis()
    _.map(@get('data').results, (row)->
      x: row[xAxis]
      y: row[yAxis]
    )

  @visualisationTypes: ['BarChart', 'Map', 'Table']
  
#For backbone relational
Backbone.Models.Visualisation.setup()
