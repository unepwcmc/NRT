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

test(".getHighestXRow should retrieve the row with the highest value of X in the indicator data", ->
  indicator = Helpers.factoryIndicator(
    indicatorDefinition:
      xAxis: 'year'
  )
  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
    data:[{
      year: 1990
    },{
      year: 2010
    }]
  )

  assert.strictEqual visualisation.getHighestXRow().year, 2010
)

test(".mapDataToXAndY should return data as an array of X and Y attributes", ->
  indicator = Helpers.factoryIndicator(
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
  )
  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
    data:[{
      year: 1990
      value: 5
    },{
      year: 2010
      value: 6
    }]
  )

  mappedData = visualisation.mapDataToXAndY()

  assert.strictEqual mappedData.length, 2
  assert.property mappedData[0], 'x'
  assert.property mappedData[0], 'y'

  assert.strictEqual mappedData[0].x, 1990
  assert.strictEqual mappedData[0].y, 5
)
