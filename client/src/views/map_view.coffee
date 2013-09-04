window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.MapView extends Backbone.View
  template: Handlebars.templates['map.hbs']
  className: 'map-view'

  initialize: (options) ->
    @visualisation = options.visualisation

  render: =>
    if @visualisation.get('data')?
      @$el.html(@template())

      setTimeout(=>
        @renderMap()
      , 500)
    else
      @visualisation.getIndicatorData()
      @render()

    return @

  onClose: ->
    
  renderMap: =>
    @map = L.map(
      @$el.find(".map-visualisation")[0],
      scrollWheelZoom: false
      attributionControl: false
    )

    L.tileLayer(
      'http://{s}.tiles.mapbox.com/v3/onlyjsmith.map-9zy5lnfp/{z}/{x}/{y}.png'
    ).addTo(@map)

    @map.on('moveend', =>
      bounds = @map.getBounds()
      minll = bounds.getSouthWest()
      maxll = bounds.getNorthEast()
      bbox = [
        [minll.lat,minll.lng],
        [maxll.lat, maxll.lng]
      ]

      @visualisation.set('map_bounds', bbox)
    )

    @fitToBounds()
    @renderDataToMap()

  fitToBounds: =>
    if @visualisation.get('map_bounds')?
      bounds = @visualisation.get('map_bounds')
    else
      bounds = [
        [26.204734267107604, 57.44750976562499],
        [22.19757745335104, 50.877685546875]
      ]

    @map.fitBounds(bounds)

  renderDataToMap: ->
    styleGeojson =
      "color": "#ff7800"
      "weight": 1
      "opacity": 0.65

    geojsonFeature = @visualisation.getHighestXRow()[@visualisation.getGeometryField()]
    L.geoJson(
      geojsonFeature
      style: styleGeojson
    ).addTo(@map)
