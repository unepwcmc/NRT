window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SubIndicatorMapView extends Backbone.View
  className: 'editable-visualisation map-visualisation'

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
        [26.204734267107604, 57.44750976562499],
        [22.19757745335104, 50.877685546875]
      ]

    @map.fitBounds(bounds)

  renderDataToMap: ->
    mostRecentData = @visualisation.getHighestXRow()
    subIndicatorData = mostRecentData[@visualisation.getSubIndicatorField()]
    markers = @subIndicatorDataToLeafletMarkers(subIndicatorData)
    debugger
    for marker in markers
      marker.addTo(@map)

  subIndicatorDataToLeafletMarkers: (subIndicators)->
    _.map(subIndicators, (subIndicator) ->
      new L.marker([subIndicator.geometry.x, subIndicator.geometry.y])
    )

  onClose: ->
    @map.off('moveend') if @map?
    @stopListening()
