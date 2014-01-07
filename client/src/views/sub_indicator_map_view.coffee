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
  renderLegend: ->
    legendControl = L.control(position: 'bottomleft')

    legendTemplate = Handlebars.templates['sub_indicator_legend.hbs']
    legendControl.onAdd = (map) =>
      div = L.DomUtil.create('div', 'legend leaflet-bar')

      subIndicatorData = @getSubIndicatorData()
      legendKeys = @uniqueSubIndicatorHeadlineTexts(subIndicatorData)
      div.innerHTML += legendTemplate(keys: legendKeys)

      div

    legendControl.addTo(@map)

  getSubIndicatorData: ->
    mostRecentData = @visualisation.getHighestXRow()
    mostRecentData[@visualisation.getSubIndicatorField()]

  renderDataToMap: ->
    subIndicatorData = @getSubIndicatorData()
    markers = @subIndicatorDataToLeafletMarkers(
      subIndicatorData,
      @visualisation.get('indicator').get('indicatorDefinition')
    )
    for marker in markers
      marker.addTo(@map)

  uniqueSubIndicatorHeadlineTexts: (subIndicators) ->
    headlineTexts = _.map(subIndicators, (subIndicator) ->
      presenter = new Nrt.Presenters.SubIndicatorDataPresenter({})
      headline = presenter.getHeadlineFromData(subIndicator)

      headline.text
    )

    _.uniq(headlineTexts)

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
