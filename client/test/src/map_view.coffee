assert = chai.assert

suite('Map View')

test('when initialised with a visualisation with no data, it fetches the data', (done)->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  indicator = visualisation.get('indicator')
  indicator.set('indicatorDefinition',
    xAxis: 'year'
    geometryField: 'geometry'
  )

  getIndicatorDataSpy = sinon.spy(visualisation, 'getIndicatorData')
  visualisation.once('dataFetched', ->
    assert.ok getIndicatorDataSpy.calledOnce
    done()
  )

  server = sinon.fakeServer.create()

  view = new Backbone.Views.MapView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  # Check we received a data request
  indicatorId = visualisation.get('indicator').get('_id')
  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{indicatorId}/data"
  )
  
  # Respond to get data request
  Helpers.SinonServer.respondWithJson.call(server, [{year: 'data', geometry: {}}])
  server.restore()

  view.close()
)

