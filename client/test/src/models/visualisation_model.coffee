assert = chai.assert

suite('Visualisation Model')

test('Passing no section into visualisation creates a null section attribute', ->
  visualisation = Factory.visualisation()
  assert.isNull visualisation.get('section')
)

test('.toJSON returns the section: as section._id instead of the model attributes', ->
  section = Factory.section()
  visualisation = new Backbone.Models.Visualisation(
    section: section
    indicator: section.get('indicator')
  )

  assert.strictEqual visualisation.toJSON().section, section.get('_id')
)

test('.toJSON returns the indicator: as indicator._id instead of the model attributes', ->
  indicatorId = Factory.findNextFreeId('Indicator')
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

test(".getIndicatorData populates the 'data' attribute", (done)->
  visualisation = Factory.visualisation()
  indicator = visualisation.get('indicator')

  server = sinon.fakeServer.create()

  visualisation.on('change:data', ->
    assert.isDefined visualisation.get('data')
    visualisation.off('change:data')
    done()
  )
  visualisation.getIndicatorData()

  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{indicator.get('_id')}/data"
  )

  Helpers.SinonServer.respondWithJson.call(server, results: {some: 'data'})

  server.restore()
)

test(".getIndicatorData calls formatData after fetching", (done)->
  visualisation = Factory.visualisation()
  server = sinon.fakeServer.create()

  formatDataSpy = sinon.spy(visualisation, 'formatData')

  visualisation.on('change:data', ->
    data = visualisation.get('data')
    try
      Helpers.assertCalledOnce formatDataSpy
      assert.property data.results[0], 'formatted',
        "Expected the formatted attribute to be populated"
      done()
    catch e
      done(e)
    finally
      visualisation.off('change:data')
  )

  visualisation.getIndicatorData()

  Helpers.SinonServer.respondWithJson.call(server, results: [{some: 'data'}])

  server.restore()
)

test(".buildIndicatorDataUrl appends visualisation filter parameters to url", ->
  visualisation = Factory.visualisation()
  visualisation.setFilterParameter('year', 'min', 2003)
  visualisation.setFilterParameter('value', 'max', 50)

  expectedUrl =
    "/api/indicators/#{
      visualisation.get('indicator').get('_id')
    }/data?filters[year][min]=2003&filters[value][max]=50"

  assert.strictEqual(decodeURI(visualisation.buildIndicatorDataUrl()), expectedUrl)
)

test(".buildIndicatorDataUrl appends file extension and params to url", ->
  visualisation = Factory.visualisation()
  visualisation.setFilterParameter('year', 'min', 2003)
  visualisation.setFilterParameter('value', 'max', 50)

  expectedUrl =
    "/api/indicators/#{
      visualisation.get('indicator').get('_id')
    }/data.csv?filters[year][min]=2003&filters[value][max]=50"

  assert.strictEqual(decodeURI(visualisation.buildIndicatorDataUrl('csv')), expectedUrl)
)

test("Default type is 'BarChart'", ->
  indicator = new Backbone.Models.Indicator()
  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
  )
  assert.strictEqual visualisation.get('type'), 'BarChart'
)

test(".getHighestXRow should retrieve the row with the highest value of X in the indicator data", ->
  indicator = Factory.indicator(
    indicatorDefinition:
      xAxis: 'year'
  )
  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
    data:
      results: [{
        year: 1990
      },{
        year: 2010
      }]
  )

  assert.strictEqual visualisation.getHighestXRow().year, 2010
)

test(".getHighestXRow the x axis is stringified dates behaves returns the
highest sorted value", ->
  indicator = Factory.indicator(
    indicatorDefinition:
      xAxis: 'date'
  )
  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
    data:
      results: [{
        date: "2013-04-01T01:00:00.000Z"
      },{
        date: "2013-01-01T01:00:00.000Z"
      }]
  )

  assert.strictEqual visualisation.getHighestXRow().date, "2013-04-01T01:00:00.000Z"
)

test(".mapDataToXAndY should return data as an array of X and Y objects, with
  formatted and non-formatted attributes", ->
  indicator = Factory.indicator(
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
  )

  visualisation = new Backbone.Models.Visualisation(
    indicator: indicator
    data:
      results: [{
        year: 1990
        value: 5
        formatted:
          year: 90
          value: 5.0
      },{
        year: 2010
        value: 6
        formatted:
          year: 10
          value: 6.0
      }]
  )

  mappedData = visualisation.mapDataToXAndY()

  assert.strictEqual mappedData.length, 2
  assert.property mappedData[0], 'x'
  assert.property mappedData[0], 'y'

  assert.strictEqual mappedData[0].x, 1990
  assert.strictEqual mappedData[0].y, 5

  assert.strictEqual mappedData[0].formatted.x, 90,
    "Expected the formatted attribute to include the x axis"
  assert.strictEqual mappedData[0].formatted.y, 5.0,
    "Expected the formatted attribute to include the y axis"
)

test('.setFilterParameter when filter is undefined 
  creates the object and insert the correct values', ->
  visualisation = Factory.visualisation()

  visualisation.setFilterParameter('year', 'min', 2004)

  assert.strictEqual visualisation.get('filters').year.min, 2004
)

test('.formatData adds a formatted object with a string formatted date for each
row of results in the given data where the type of the field is date', ->
  indicator = Factory.indicator(
    indicatorDefinition:
      fields: [
        name: 'date'
        type: 'date'
      ]
  )
  dataToFormat =
    results: [
      date: '2013-04-01T01:00:00.000Z'
      otherField: 'an value'
    ]
  visualisation = Factory.visualisation(
    indicator: indicator
  )

  formattedData = visualisation.formatData(dataToFormat)
  formattedRow = formattedData.results[0]

  assert.property formattedRow, 'formatted',
    'Expected the data to have a formatted attribute'
  assert.property formattedRow.formatted, 'date',
    'Expected the formatted data to include the date'
  assert.strictEqual formattedRow.formatted.date, '2013-04-01',
    'Expected the formatted date to be formatted YYYY-MM-DD'
  assert.strictEqual formattedRow.formatted.otherField, 'an value',
    "Expected the otherField to be included in the formatted data, but unmodified"
)

test('.getVisualisationTypes returns LineChart, Map types if the
  Indicator Data has any subIndicators', ->
  indicator = Factory.indicator(
    indicatorDefinition:
      subIndicatorField: "station"
  )

  data =
    results: [
      station: [
        date: 1357002000000
        station: "Al Ein"
        value: 53.6857
        text: "Great"
      ]
    ]

  visualisation = Factory.visualisation(
    indicator: indicator
    data: data
  )

  visualisationTypes = visualisation.getVisualisationTypes()

  assert.lengthOf visualisationTypes, 2

  expectedSubIndicatorTypes = Backbone.Models.Visualisation.types.subIndicatorTypes
  assert.deepEqual visualisationTypes, expectedSubIndicatorTypes,
    "Expected the visualisation types available to be sub-indicator types"
)

test('.getVisualisationTypes returns BarChart, Map and Table types if the
  Indicator Data does not have any subIndicators', ->
  indicator = Factory.indicator()

  visualisation = Factory.visualisation(
    indicator: indicator
  )

  visualisationTypes = visualisation.getVisualisationTypes()

  assert.lengthOf visualisationTypes, 3

  expectedNonSubIndicatorTypes = Backbone.Models.Visualisation.types.nonSubIndicatorTypes
  assert.deepEqual visualisationTypes, expectedNonSubIndicatorTypes,
    "Expected the visualisation types available to be non sub-indicator types"
)
