assert = chai.assert

suite('Visualisation Model')

test('Passing an indicator into a visualisation
  should assign it to the visualisation attribute', ->
  indicator = new Backbone.Models.Indicator()
  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
  )

  assert.strictEqual visualisation.get('indicator').cid, indicator.cid
)

test('Initializing a visualisation without an indicator throws an error', ->
  assert.throw( ->
    new Backbone.Models.Visualisation()
  , "You must initialise Visualisations with an Indicator")
)

test(".getIndicatorData populates the 'data' attribute and triggers 'dataFetched'", (done)->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  indicator = visualisation.get('indicator')

  server = sinon.fakeServer.create()

  visualisation.on('dataFetched', ->
    assert.isDefined visualisation.get('data')
    visualisation.off('dataFetched')
    done()
  )
  visualisation.getIndicatorData()

  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{indicator.get('_id')}/data"
  )

  Helpers.SinonServer.respondWithJson.call(server, {some: 'data'})

  server.restore()
)
