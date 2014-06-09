assert = require('chai').assert
helpers = require '../helpers'
_ = require('underscore')
Q = require('q')
Promise = require('bluebird')
sinon = require('sinon')

Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
Page = require('../../models/page').model

HeadlineService = require '../../lib/services/headline'

suite('Indicator')

test('.getIndicatorDataForCSV with no filters returns all indicator data in a 2D array', (done) ->
  data = [
    {
      "year": 2000,
      "value": 4
    }, {
      "year": 2001,
      "value": 4
    }, {
      "year": 2002,
      "value": 4
    }
  ]

  expectedData = [
    ['year', 'value'],
    ["2000","4"],
    ["2001","4"],
    ["2002","4"]
  ]

  indicator = new Indicator(
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
  )
  indicatorData = new IndicatorData(
    data: data
  )

  Q.nsend(
    indicator, 'save'
  ).then(->
    indicatorData.indicator = indicator

    Q.nsend(
      indicatorData, 'save'
    )
  ).then( ->

    indicator.getIndicatorDataForCSV( (err, indicatorData) ->
      assert.ok(
        _.isEqual(indicatorData, expectedData),
        "Expected \n#{JSON.stringify(indicatorData)} \nto equal \n#{JSON.stringify(expectedData)}"
      )
      done()
    )

  ).catch((err) ->
    console.error err
    throw err
  )
)

test('.getIndicatorDataForCSV converts all fields to String', (done) ->
  data = [
    {
      "date": new Date(2000, 12),
      "value": 4
    }
  ]

  indicator = new Indicator(
    indicatorDefinition:
      xAxis: 'date'
      yAxis: 'value'
  )

  getIndicatorDataStub = sinon.stub(indicator, 'getIndicatorData', (filters, callback) ->
    callback(null, data)
  )

  try
    indicator.getIndicatorDataForCSV( (err, indicatorData) ->
      if err?
        getIndicatorDataStub.restore()
        return done(err)

      date = indicatorData[1][0]
      value = indicatorData[1][1]

      assert.typeOf date, 'string'
      assert.typeOf value, 'string'

      assert.match date, /Mon Jan 01 2001 00:00:00 GMT\+0000/
      assert.strictEqual value, "4"

      done()
    )
  catch err
    getIndicatorDataStub.restore()
    done(err)
)

test('.getIndicatorDataForCSV with filters returns data matching filters in a 2D array', (done) ->
  data = [
    {
      "year": 2000,
      "value": 3
    }, {
      "year": 2001,
      "value": 4
    }, {
      "year": 2002,
      "value": 4
    }
  ]

  expectedData = [
    ['year', 'value'],
    ["2001","4"],
    ["2002","4"]
  ]

  indicator = new Indicator(
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
  )
  indicatorData = new IndicatorData(
    data: data
  )

  filters =
    value:
      min: '4'

  Q.nsend(
    indicator, 'save'
  ).then(->
    indicatorData.indicator = indicator

    Q.nsend(
      indicatorData, 'save'
    )
  ).then( ->

    indicator.getIndicatorDataForCSV( filters, (err, indicatorData) ->
      assert.ok(
        _.isEqual(indicatorData, expectedData),
        "Expected \n#{JSON.stringify(indicatorData)} \nto equal \n#{JSON.stringify(expectedData)}"
      )
      done()
    )

  ).catch((err) ->
    console.error err
    throw err
  )
)

test('.getIndicatorData with no filters returns all indicator data for this indicator', (done) ->
  expectedData = [
    {
      "year": 2000,
      "value": 4
    }, {
      "year": 2001,
      "value": 4
    }, {
      "year": 2002,
      "value": 4
    }
  ]

  indicator = new Indicator()
  indicatorData = new IndicatorData(
    data: expectedData
  )

  Q.nsend(
    indicator, 'save'
  ).then(->
    indicatorData.indicator = indicator

    Q.nsend(
      indicatorData, 'save'
    )
  ).then( ->

    indicator.getIndicatorData((err, data) ->
      assert.ok(
        _.isEqual(data, expectedData),
        "Expected \n#{JSON.stringify(data)} \nto equal \n#{JSON.stringify(expectedData)}"
      )
      done()
    )

  ).catch((err) ->
    console.error err
    throw err
  )
)

test('.getIndicatorData with an integer filter \'min\' value
  returns the data correctly filtered', (done) ->
  fullData = [
    {
      "year": 2000,
      "value": 3
    }, {
      "year": 2001,
      "value": 4
    }, {
      "year": 2002,
      "value": 7
    }
  ]
  expectedFilteredData = [fullData[1], fullData[2]]

  indicator = new Indicator()
  indicatorData = new IndicatorData(
    data: fullData
  )

  filters =
    value:
      min: '4'

  Q.nsend(
    indicator, 'save'
  ).then(->
    indicatorData.indicator = indicator

    Q.nsend(
      indicatorData, 'save'
    )
  ).then( ->

    indicator.getIndicatorData(filters, (err, data) ->
      assert.ok(
        _.isEqual(data, expectedFilteredData),
        "Expected \n#{JSON.stringify(data)} \nto equal \n#{JSON.stringify(expectedFilteredData)}"
      )
      done()
    )

  ).catch((err) ->
    console.error err
    throw err
  )
)

test('.getIndicatorData on an indicator with no indicator data
  returns an empty array', (done) ->
  indicator = new Indicator()

  indicator.getIndicatorData((err, data) ->
    if err?
      throw err

    assert.ok _.isEqual(data, []), "Expected returned data to be an empty array"
    done()
  )
)

test('#calculateIndicatorDataBounds should return the upper and lower bounds of data', (done) ->
  indicatorData = [
    {
      "year": 2000,
      "value": 2
    }, {
      "year": 2001,
      "value": 9
    }, {
      "year": 2002,
      "value": 4
    }
  ]

  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        name: 'year'
        type: 'integer'
      }, {
        name: "value",
        type: "integer"
      }]
  )
  indicatorData = new IndicatorData(
    data: indicatorData
  )


  Q.nsend(
    indicator, 'save'
  ).then(->
    indicatorData.indicator = indicator

    Q.nsend(
      indicatorData, 'save'
    )
  ).then( ->

    indicator.calculateIndicatorDataBounds((err, data) ->
      assert.property(
        data, 'year'
      )
      assert.property(
        data, 'value'
      )

      assert.strictEqual(data.year.min, 2000)
      assert.strictEqual(data.year.max, 2002)

      assert.strictEqual(data.value.min, 2)
      assert.strictEqual(data.value.max, 9)
      done()
    )

  ).catch((err) ->
    console.error err
    throw err
  )
)

test('.getPage should be mixed in', ->
  indicator = new Indicator()
  assert.typeOf indicator.getPage, 'Function'
)

test('.getFatPage should be mixed in', ->
  indicator = new Indicator()
  assert.typeOf indicator.getFatPage, 'Function'
)

test(".toObjectWithNestedPage is mixed in", ->
  indicator = new Indicator()
  assert.typeOf indicator.toObjectWithNestedPage, 'Function'
)

test("#findWhereIndicatorHasData returns only indicators with indicator data", (done)->
  indicatorWithData = indicatorWithoutData = null

  helpers.createIndicatorModels([{},{}]).then((indicators) ->
    indicatorWithData = indicators[0]
    indicatorWithoutData = indicators[1]

    helpers.createIndicatorData({
      indicator: indicatorWithData
      data: [{some: 'data'}]
    })
  ).then((indicatorData) ->
    Indicator.findWhereIndicatorHasData()
  ).then((indicators) ->

    assert.lengthOf indicators, 1, "Expected only the one indicator with data to be returned"
    assert.strictEqual indicators[0]._id.toString(), indicatorWithData._id.toString(),
      "Expected the returned indicator to be the indicator with data"

    done()

  ).catch((err) ->
    console.error err
    console.error err.stack
    throw err
  )

)


test("#findWhereIndicatorHasData respects the given filters", (done)->
  indicatorToFind = indicatorToFilterOut = null

  helpers.createIndicatorModels([{},{}]).then((indicators) ->
    indicatorToFind = indicators[0]
    indicatorToFilterOut = indicators[1]

    helpers.createIndicatorData({
      indicator: indicatorToFind
      data: [{some: 'data'}]
    })
  ).then((indicatorData) ->

    helpers.createIndicatorData({
      indicator: indicatorToFilterOut
      data: [{some: 'data'}]
    })
  ).then((indicatorData) ->
    Indicator.findWhereIndicatorHasData(_id: indicatorToFind._id)
  ).then((indicators) ->

    assert.lengthOf indicators, 1, "Expected only the one indicator with data to be returned"
    assert.strictEqual indicators[0]._id.toString(), indicatorToFind._id.toString(),
      "Expected the returned indicator to be the indicator with data"

    done()

  ).catch((err) ->
    console.error err
    console.error err.stack
    throw err
  )
)

test(".hasData returns true when an indicator has data", (done)->
  indicatorWithData = null

  helpers.createIndicatorModels([{}]).then((indicators) ->
    indicatorWithData = indicators[0]

    helpers.createIndicatorData({
      indicator: indicatorWithData
      data: [{some: 'data'}]
    })
  ).then((indicatorData) ->
    indicatorWithData.hasData()
  ).then((hasData) ->

    try
      assert.isTrue hasData
      done()
    catch err
      done(err)

  ).catch(done)
)

test(".hasData returns false when an indicator has no data", (done)->
  helpers.createIndicatorModels([{}]).then((indicators) ->
    indicators[0].hasData()
  ).then((hasData) ->
    try
      assert.isFalse hasData
      done()
    catch err
      done(err)
  ).catch(done)
)

test('#populatePages given an array of indicators, populates their page attributes', (done) ->
  indicator = new Indicator()
  page = new Page()
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  Indicator.populatePages([indicator]).then( ->
    assert.ok _.isEqual(indicator.page, page),
      "Expected the page attribute to be populated with the indicator page"
    done()
  ).catch((err) ->
    console.error err
    throw err
  )
)

test("#calculateBoundsForType when given an unkown type returns null", ->
  bounds = Indicator.calculateBoundsForType("party", [], 'fieldName')

  assert.isNull bounds, "Expected returned bounds to be null"
)

test("#calculateBoundsForType given an array of dates returns the correct bounds", ->
  dates = [
    {value: new Date("2011")},
    {value: new Date("2016")},
    {value: new Date("2014")}
  ]
  bounds = Indicator.calculateBoundsForType("date", dates, 'value')

  assert.strictEqual bounds.min.getFullYear(), 2011
  assert.strictEqual bounds.max.getFullYear(), 2016
)

test("#calculateBoundsForType given text returns null", ->
  text = [
    {value: 'hat'},
    {value: 'boat'}
  ]
  bounds = Indicator.calculateBoundsForType("text", text, 'value')

  assert.isNull bounds
)

test('.convertNestedParametersToAssociationIds converts a Theme object to a Theme ID', ->
  indicator = new Indicator()
  theme = new Theme()

  indicatorAttributes = indicator.toObject()
  indicatorAttributes.theme = theme.toObject()

  indicatorWithThemeId = Indicator.convertNestedParametersToAssociationIds(indicatorAttributes)

  assert.strictEqual(
    indicatorWithThemeId.theme,
    theme.id,
    'Expected indicator theme to be an ID only'
  )
)

test(".generateMetadataCSV returns CSV arrays containing the name, theme,
  period and data date", (done) ->
  theIndicator = theTheme = newestHeadlineStub = null

  Q.nsend(
    Theme, 'create', {
      title: 'Air Quality'
    }
  ).then( (theme) ->
    theTheme = theme

    Q.nsend(
      Indicator, 'create', {
        name: "Anne Test Indicator"
        theme: theme
        indicatorDefinition:
          period: 'quarterly'
          xAxis: 'year'
      }
    )
  ).then( (indicator) ->
    theIndicator = indicator

    newestHeadlineStub = sinon.stub(HeadlineService::, 'getNewestHeadline', ->
      Q.fcall(->
        year: 2006
      )
    )

    theIndicator.generateMetadataCSV()
  ).then((csvData) ->

    try
      assert.lengthOf csvData, 2, "Expected data to have 2 rows: header and data"
      titleRow = csvData[0]
      dataRow = csvData[1]

      assert.strictEqual titleRow[0], 'Indicator',
        "Expected the first column to be the indicator name"
      assert.strictEqual dataRow[0], theIndicator.name,
        "Expected the indicator name to be the name of the indicator"

      assert.strictEqual titleRow[1], 'Theme', "Expected the second column to be the theme"
      assert.strictEqual dataRow[1], theTheme.title,
        "Expected the theme to be the name of the indicator's theme"

      assert.strictEqual titleRow[2], 'Collection Frequency',
        "Expected the 3rd column to be the collection frequency"
      assert.strictEqual dataRow[2], theIndicator.indicatorDefinition.period,
        "Expected the Collection Frequency to be the indicator's period"

      assert.strictEqual titleRow[3], 'Date Updated',
        "Expected the 4th column to be the date updated"
      assert.strictEqual dataRow[3], 2006,
        "Expected the date updated to be 2006"

      done()
    catch e
      done(e)
    finally
      newestHeadlineStub.restore()

  ).catch( (err) ->
    done(err)
    newestHeadlineStub.restore()
  )
)

test(".generateMetadataCSV on an indicator with no theme or indicator defintion
returns blank values for those fields", (done) ->
  indicator = new Indicator()

  indicator.generateMetadataCSV().then( (csvData)->
    try
      assert.lengthOf csvData, 2, "Expected data to have 2 rows: header and data"
      titleRow = csvData[0]
      dataRow = csvData[1]

      assert.strictEqual titleRow[1], 'Theme', "Expected the second column to be the theme"
      assert.isUndefined dataRow[1], "Expected the theme to be blank"

      assert.strictEqual titleRow[2], 'Collection Frequency',
        "Expected the 3rd column to be the collection frequency"
      assert.isUndefined dataRow[2], "Expected the Collection Frequency to be blank"

      assert.strictEqual titleRow[3], 'Date Updated',
        "Expected the 4th column to be the date updated"
      assert.strictEqual dataRow[3], '', "Expected the date updated to be blank"

      done()
    catch e
      done(e)

  ).catch( (err) ->
    done(err)
  )
)

test("#seedData when no seed file exist reports an appropriate error", (done) ->
  fs = require('fs')
  existsSyncStub = sinon.stub(fs, 'existsSync', -> false)

  Indicator.seedData('./config/seeds/indicators.json').then( ->
    done("Expected Indicator.seedData to fail")
  ).catch( (err)->

    assert.strictEqual(
      err.message,
      "Unable to load indicator seed file, have you copied seeds from config/instances/ to config/seeds/?"
    )
    done()

  ).finally( ->
    existsSyncStub.restore()
  )
)

test('#CONDITIONS.IS_PRIMARY only returns indicators with indicators
  with primary: true', (done) ->
  helpers.createIndicatorModels([{
    primary: true
  }, {
    primary: false
  }]).then(->
    Indicator.find(Indicator.CONDITIONS.IS_PRIMARY).exec()
  ).then((indicators)->
    try
      assert.lengthOf indicators, 1,
        "Only expected the primary indicator to be returned"

      done()
    catch err
      done(err)
  ).catch(done)

)

test('creating a new Indicator without an "indicatorationConfig" attribute
  initialises it with a empty object', ->
  indicator = new Indicator()

  assert.deepEqual indicator.indicatorationConfig, {},
    "Expected indicator.indicatoration to be defaulted to {}"
)
