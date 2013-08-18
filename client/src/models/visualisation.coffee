window.Backbone.Models || = {}

class window.Backbone.Models.Visualisation extends Backbone.RelationalModel
  formatDataForChart: ->
     _.map(@get("data"), (el) -> {Year: el.year, Percentage: el.value})

  url: '/api/visualisation'

  getIndicatorData: ->
    $.get(@buildIndicatorDataUrl(), (data)=>
      @set('data', data)
      @trigger('dataFetched')
    )

  buildIndicatorDataUrl: ->
    "/api/indicators/#{@get('section').get('indicator').get('id')}/data"

#For backbone relational
Backbone.Models.Visualisation.setup()
