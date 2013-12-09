window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.MapView extends Backbone.View
  className: 'section-visualisation map-visualisation'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change:data', @render)
    @render()

  render: =>
    if @visualisation.get('data')?
      setTimeout(=>
        @renderMap()
      , 500)
    else
      @visualisation.getIndicatorData()

    return @

  renderMap: =>
    @map = L.map(
      @el,
      scrollWheelZoom: false
      attributionControl: false
    )

    L.tileLayer(
      'http://{s}.tiles.mapbox.com/v3/onlyjsmith.map-9zy5lnfp/{z}/{x}/{y}.png'
    ).addTo(@map)

    @fitToBounds()
    @renderDataToMap()

  saveMapBounds: =>
    bounds = @map.getBounds()
    minll = bounds.getSouthWest()
    maxll = bounds.getNorthEast()
    bbox = [
      [minll.lat,minll.lng],
      [maxll.lat, maxll.lng]
    ]

    @visualisation.set('map_bounds', bbox)

  fitToBounds: =>
    if @visualisation.get('map_bounds') and @visualisation.get('map_bounds').length > 1 ?
      bounds = @visualisation.get('map_bounds')
    else
      bounds = [
        [52.802761415419674, 27.9052734375],
        [40.84706035607122, 0.3076171875]
      ]

    @map.fitBounds(bounds)

  renderDataToMap: ->
    serviceName = @visualisation.get('indicator').get('indicatorDefinition').serviceName
    serviceName ||= "NRT_AD_ProtectedArea"
    L.esri.dynamicMapLayer("http://196.218.36.14/ka/rest/services/#{serviceName}/MapServer",
      opacity: 0.6
    ).addTo(@map)

  onClose: ->
    @map.off('moveend') if @map?
    @stopListening()
