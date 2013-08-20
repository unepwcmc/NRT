window.Backbone.Models || = {}

class window.Backbone.Models.Visualisation extends Backbone.RelationalModel

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

  @visualisationTypes: ['BarChart', 'Map', 'Table']
  
#For backbone relational
Backbone.Models.Visualisation.setup()
