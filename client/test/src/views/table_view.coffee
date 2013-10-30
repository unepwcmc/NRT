assert = chai.assert

suite('Table View')

test('when initialised with a visualisation with no data, it fetches the data', (done)->
  visualisation = Factory.visualisation(
    data: null
  )

  visualisation.get('indicator').set('indicatorDefinition',
    xAxis: 'year'
    yAxis: 'value'
  )

  getIndicatorDataSpy = sinon.spy(visualisation, 'getIndicatorData')
  visualisation.once('change:data', ->
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
  Helpers.SinonServer.respondWithJson.call(server, results: [{
      year: 1990
      value: 5
  }])
  server.restore()

  view.close()
)

test('Should render formatted visualisation data into a table', ->
  visualisation = Factory.visualisation()
  visualisation.set('data', results: [{
      year: 2015
      value: 10
      formatted:
        year: 2015
        value: 10.0
    },{
      year: 2014
      value: 8
      formatted:
        year: 2014
        value: 8.0
  }])

  indicator = visualisation.get('indicator')
  indicator.set(
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
    title: 'An indicatr'
  )

  view = new Backbone.Views.TableView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  assert.strictEqual(
    $('#test-container').find('table caption').text(),
    indicator.get('title')
  )

  headerText = $('#test-container').find('table thead').text()

  assert.match headerText, new RegExp(".*#{visualisation.getXAxis()}.*")
  assert.match headerText, new RegExp(".*#{visualisation.getYAxis()}.*")

  bodyText = $('#test-container').find('table tbody').text()

  assert.match bodyText, /.*2015.*/
  assert.match bodyText, /.*10\.0.*/,
    "Expected the body text to include the formatted values"

  view.close()
)
