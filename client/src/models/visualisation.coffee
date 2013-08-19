window.Backbone.Models || = {}

class window.Backbone.Models.Visualisation extends Backbone.RelationalModel
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

#For backbone relational
Backbone.Models.Visualisation.setup()
