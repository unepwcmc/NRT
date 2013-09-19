assert = chai.assert

suite('Line Chart View')

test('when initialised with a visualisation with no data, it fetches the data', (done)->
  visualisation = Factory.visualisation(
    data: null
    type: 'LineChart'
  )

  getIndicatorDataSpy = sinon.spy(visualisation, 'getIndicatorData')
  visualisation.once('change:data', ->
    assert.ok getIndicatorDataSpy.calledOnce
    done()
  )

  server = sinon.fakeServer.create()

  view = new Backbone.Views.LineChartView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  # Check we received a data request
  indicatorId = visualisation.get('indicator').get('_id')
  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{indicatorId}/data"
  )

  # Respond to get data request
  Helpers.SinonServer.respondWithJson.call(server, {results: [
    {
      text: "Below Threshold",
      value: 3,
      year: '2000'
    },
    {
      text: "Below Threshold",
      value: 4,
      year: '2001'
    },
    {
      text: "Below Threshold",
      value: 3,
      year: '2002'
    },
    {
      text: "Below Threshold",
      value: 6,
      year: '2003'
    }]})

  server.restore()

  # Uncomment to hide the chart in the test page
  #view.close()
)