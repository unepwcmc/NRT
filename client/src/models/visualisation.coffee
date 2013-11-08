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
    $.get(@buildIndicatorDataUrl()).done((data)=>
      @set('data', @formatData(data))
    ).fail((jqXHR, textStatus, error) ->
      throw new Error("Error fetching indicator data: #{error}")
    )

  buildIndicatorDataUrl: (fileExtension) ->
    fileExtension = if fileExtension? then ".#{fileExtension}" else ""
    url = "/api/indicators/#{@get('indicator').get('_id')}/data#{fileExtension}"
    if @get('filters')?
      url += "?#{
        $.param {filters: @get('filters')}
      }"
    return url

  getXAxis: ->
    @get('indicator').get('indicatorDefinition').xAxis

  getYAxis: ->
    @get('indicator').get('indicatorDefinition').yAxis

  getGeometryField: ->
    @get('indicator').get('indicatorDefinition').geometryField

  getSubIndicatorField: ->
    @get('indicator').get('indicatorDefinition').subIndicatorField

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
      formatted:
        x: row.formatted[xAxis]
        y: row.formatted[yAxis]
    )

  setFilterParameter: (field, operation, value)->
    filters = @get('filters')
    filters ||= {}
    filters[field] ||= {}
    filters[field][operation] = value

    @set('filters', filters)

  formatData: (data) ->
    for row in data.results
      row.formatted ||= {}
      for key, value of row
        break if key is 'formatted'
        if @get('indicator').getFieldType(key) is 'date'
          date = new Date(value)
          row.formatted[key] = date.toISOString().replace(/T.*/, '')
        else
          row.formatted[key] ||= value

    return data

  getVisualisationTypes: ->
    subIndicatorField = @getSubIndicatorField()
    if subIndicatorField?
      return Visualisation.types.subIndicatorTypes
    else
      return Visualisation.types.nonSubIndicatorTypes

  @types:
    subIndicatorTypes: ['LineChart']
    nonSubIndicatorTypes: ['BarChart', 'Map', 'Table']

#For backbone relational
Backbone.Models.Visualisation.setup()
