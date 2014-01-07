window.Backbone ||= {}
window.Backbone.Views ||= {}
window.Libs ||= {}

Libs.LeafletHelpers =
  generatePopupText: (data, indicatorDefinition) ->
    presenter = new Nrt.Presenters.SubIndicatorDataPresenter(indicatorDefinition)

    headline = presenter.getHeadlineFromData(data)
    subIndicatorValue = presenter.getSubIndicatorIdentifier(data)

    text = "<h3>#{subIndicatorValue}</h3>"
    text += "#{headline.text}: #{headline.value} #{headline.unit}"

  defaultIconOptions:
    iconUrl: '/images/map-marker.png'
    iconRetinaUrl: '/images/map-markerX2.png'
    iconSize:     [10, 10]
    iconAnchor:   [0, 0]
    popupSize:   [0, 0]
    shadowSize:   [0, 0]

class Backbone.Views.SubIndicatorMapView extends Backbone.Views.MapView
  renderDataToMap: ->
    mostRecentData = @visualisation.getHighestXRow()
    subIndicatorData = mostRecentData[@visualisation.getSubIndicatorField()]
    markers = @subIndicatorDataToLeafletMarkers(
      subIndicatorData,
      @visualisation.get('indicator').get('indicatorDefinition')
    )
    for marker in markers
      marker.addTo(@map)

  subIndicatorDataToLeafletMarkers: (subIndicators, indicatorDefinition)->
    _.map(subIndicators, (subIndicator) ->
      iconOptions = {className: Utilities.cssClassify(subIndicator.text)}
      _.extend(iconOptions, Libs.LeafletHelpers.defaultIconOptions)

      marker = new L.marker(
        [subIndicator.geometry.y, subIndicator.geometry.x],
        icon: L.icon(iconOptions)
      )
      marker.bindPopup(Libs.LeafletHelpers.generatePopupText(subIndicator, indicatorDefinition))
    )
