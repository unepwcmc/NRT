assert = chai.assert

suite('Visualisation Model')

test('Passing no section into visualisation creates a null section attribute', ->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  assert.isNull visualisation.get('section')
)

test('.toJSON returns the section: as section._id instead of the model attributes', ->
  section = Helpers.factorySectionWithIndicator()
  section.set('_id', 34)
  visualisation = new Backbone.Models.Visualisation(
    section: section
    indicator: section.get('indicator')
  )

  assert.strictEqual visualisation.toJSON().section, section.get('_id')
)

test('.toJSON returns the indicator: as indicator._id instead of the model attributes', ->
  indicatorId = Helpers.findNextFreeId('Indicator')
  visualisation = new Backbone.Models.Visualisation(
    indicator: {
      _id: indicatorId
      title: 'hey'
    }
  )

  assert.strictEqual visualisation.toJSON().indicator, indicatorId
)

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

test("Default type is 'BarChart'", ->
  indicator = new Backbone.Models.Indicator()
  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
  )
  assert.strictEqual visualisation.get('type'), 'BarChart'
)



