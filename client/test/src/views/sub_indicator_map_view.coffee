assert = chai.assert

suite('Sub Indicator Map View')

test('when initialised with a visualisation with no data, it fetches the data', (done)->
  visualisation = Factory.visualisation(
    data: null
  )

  indicator = visualisation.get('indicator')
  indicator.set('indicatorDefinition',
    xAxis: 'year'
    geometryField: 'geometry'
  )

  getIndicatorDataSpy = sinon.spy(visualisation, 'getIndicatorData')
  visualisation.once('change:data', ->
    assert.ok getIndicatorDataSpy.calledOnce
    done()
  )

  server = sinon.fakeServer.create()

  view = new Backbone.Views.SubIndicatorMapView(visualisation: visualisation)

  # Check we received a data request
  indicatorId = visualisation.get('indicator').get('_id')
  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{indicatorId}/data"
  )
  
  # Respond to get data request
  Helpers.SinonServer.respondWithJson.call(server, results: [{year: 'data', geometry: {}}])
  server.restore()

  view.close()
)

test('.subIndicatorDataToLeafletMarkers converts sub indicator geometries to
leaflet markers', ->
  subIndicatorData = [
    geometry:
      x: 5
      y: 10
  ]
  indicatorDefinition =
    fields: []

  markers = Backbone.Views.SubIndicatorMapView::subIndicatorDataToLeafletMarkers(
    subIndicatorData, indicatorDefinition
  )

  assert.lengthOf markers, 1,
    "Only expected one leaflet marker"

  marker = markers[0]
  latLng = marker.getLatLng()
  assert.strictEqual latLng.lat, 10,
    "Expected the marker to have the right x value"
  assert.strictEqual latLng.lng, 5,
    "Expected the marker to have the right y value"
)

test('.subIndicatorDataToLeafletMarkers sets leaflet marker icon className based on the subIndicator status', ->
  subIndicatorData = [
    text: 'Excellent'
    geometry:
      x: 5
      y: 10
  ]
  indicatorDefinition =
    fields: []

  markers = Backbone.Views.SubIndicatorMapView::subIndicatorDataToLeafletMarkers(
    subIndicatorData, indicatorDefinition
  )

  assert.lengthOf markers, 1,
    "Only expected one leaflet marker"

  marker = markers[0]
  icon = marker.options.icon
  assert.strictEqual icon.options.className, 'excellent',
    "Expected the marker to have the right classname set"
)

test('.uniqueSubIndicatorHeadlineTexts returns a unique list of all the headline texts', ->
  subIndicatorData = [{
    text: 'awesome'
  },{
    text: 'horrid'
  },{
    text: 'awesome'
  }]
  indicatorDefinition =
    fields: []

  texts = Backbone.Views.SubIndicatorMapView::uniqueSubIndicatorHeadlineTexts(
    subIndicatorData
  )

  assert.lengthOf texts, 2, 'Only expected one headline text'

  assert.strictEqual texts[0], 'awesome',
    'Expected the first headline text to be "awesome"'

  assert.strictEqual texts[1], 'horrid',
    'Expected the second headline text to be "horrid"'
)
