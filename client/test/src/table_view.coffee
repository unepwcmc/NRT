assert = chai.assert

suite('Table View')

test('when initialised with a visualisation with no data, it fetches the data', (done)->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  visualisation.get('indicator').set('indicatorDefinition',
    xAxis: 'year'
    yAxis: 'value'
  )

  getIndicatorDataSpy = sinon.spy(visualisation, 'getIndicatorData')
  visualisation.once('dataFetched', ->
    assert.ok getIndicatorDataSpy.calledOnce
    done()
  )

  server = sinon.fakeServer.create()

  view = new Backbone.Views.TableView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  # Check we received a data request
  indicatorId = visualisation.get('indicator').get('_id')
  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{indicatorId}/data"
  )

  # Respond to get data request
  Helpers.SinonServer.respondWithJson.call(server, [{
      year: 1990
      value: 5
  }])
  server.restore()

  view.close()
)

test('Should render visualisation data into a table', ->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  visualisation.set('data', [{
      year: 2015
      value: 10
    },{
      year: 2014
      value: 8
  }])
  visualisation.get('indicator').set('indicatorDefinition',
    xAxis: 'year'
    yAxis: 'value'
  )

  view = new Backbone.Views.TableView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  headerText = $('#test-container').find('table thead').text()

  assert.match headerText, new RegExp(".*#{visualisation.getXAxis()}.*")
  assert.match headerText, new RegExp(".*#{visualisation.getYAxis()}.*")

  bodyText = $('#test-container').find('table tbody').text()

  assert.match bodyText, /.*2015.*/
  assert.match bodyText, /.*10.*/
)
