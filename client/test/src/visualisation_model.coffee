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

test(".mapDataToXAndY should return data as an array of X and Y attributes", ->
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

test('.setFilterParameter when filter is undefined 
  creates the object and insert the correct values', ->
  visualisation = Factory.visualisation()

  visualisation.setFilterParameter('year', 'min', 2004)

  assert.strictEqual visualisation.get('filters').year.min, 2004
)
