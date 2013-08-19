assert = chai.assert

suite('Bar Chart View')

test('when initialised with a visualisation with no data, it fetches the data', (done)->
  visualisation = Helpers.factoryVisualisationWithIndicator()

  getIndicatorDataSpy = sinon.spy(visualisation, 'getIndicatorData')
  visualisation.once('dataFetched', ->
    assert.ok getIndicatorDataSpy.calledOnce
    done()
  )

  server = sinon.fakeServer.create()

  view = new Backbone.Views.BarChartView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  # Check we received a data request
  indicatorId = visualisation.get('section').get('indicator').get('_id')
  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{indicatorId}/data"
  )
  
  # Respond to get data request
  Helpers.SinonServer.respondWithJson.call(server, {some: 'data'})
  server.restore()

  view.close()
)
