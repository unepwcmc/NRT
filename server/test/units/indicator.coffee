assert = require('chai').assert
helpers = require '../helpers'
async = require('async')
_ = require('underscore')
Q = require 'q'
sinon = require 'sinon'

Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
Page = require('../../models/page').model

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
    [2000,4],
    [2001,4],
    [2002,4]
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

  ).fail((err) ->
    console.error err
    throw err
  )
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
    [2001,4],
    [2002,4]
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

  ).fail((err) ->
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

  ).fail((err) ->
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

  ).fail((err) ->
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

test('.getRecentHeadlines returns the given number of most recent headlines
  in decending date order with the period end calculated for annual
  indicator data', (done)->
  indicatorData = [
    {
      "year": 2000,
      "value": 2
      "text": 'Poor'
    }, {
      "year": 2001,
      "value": 9
      "text": 'Great'
    }, {
      "year": 2002,
      "value": 4
      "text": 'Fair'
    }
  ]

  indicatorDefinition =
    xAxis: 'year'
    yAxis: 'value'
    textField: 'text'
    fields: [{
      name: 'year'
      type: 'integer'
    }, {
      name: "value",
      type: "integer"
    }, {
      name: 'text'
      name: 'text'
    }]

  theIndicator = null

  Q.nsend(
    Indicator, 'create',
      indicatorDefinition: indicatorDefinition
  ).then( (indicator) ->
    theIndicator = indicator

    Q.nsend(
      IndicatorData, 'create'
        indicator: theIndicator
        data: indicatorData
    )
  ).then( ->
    theIndicator.getRecentHeadlines(2)
  ).then( (data) ->

    assert.lengthOf data, 2, "Expected 2 headlines to be returned"

    mostRecentHeadline = data[0]

    assert.strictEqual(mostRecentHeadline.year, 2002,
      "Expected most recent headline year value to be 2002")
    assert.strictEqual(mostRecentHeadline.value, 4,
      "Expected most recent headline value to be 4")
    assert.strictEqual(mostRecentHeadline.text, "Fair",
      "Expected most recent headline text to be 'Fair'")

    assert.strictEqual(mostRecentHeadline.periodEnd, "31 Dec 2002",
      "Expected most recent headline period end to be '31 Dec 2002")

    done()

  ).fail((err) ->
    console.error err
    throw err
  )
)

test('.getRecentHeadlines successfully returns all headline when the
  number of headlines requested is undefined', (done)->
  indicatorData = [
    {
      "year": 1999,
      "value": 3
      "text": 'Poor'
    },
    {
      "year": 2000,
      "value": 2
      "text": 'Poor'
    }
  ]

  indicator = new Indicator()
  sinon.stub(indicator, 'getIndicatorData', (callback) ->
    callback(null, indicatorData)
  )

  indicator.getRecentHeadlines()
  .then( (data) ->

    assert.lengthOf data, 2, "Expected 2 headlines to be returned"

    mostRecentHeadline = data[0]

    assert.strictEqual(mostRecentHeadline.year, 2000,
      "Expected most recent headline year value to be 2000")
    assert.strictEqual(mostRecentHeadline.value, 2,
      "Expected most recent headline value to be 2")
    assert.strictEqual(mostRecentHeadline.text, "Poor",
      "Expected most recent headline text to be 'Poor'")

    done()

  ).fail((err) ->
    console.error err
    throw err
  )
)

test('.getNewestHeadline returns the most recent headline', (done)->
  indicatorData = [
    {
      "year": 2001,
      "value": 9
      "text": 'Great'
    }, {
      "year": 2002,
      "value": 4
      "text": 'Fair'
    }
  ]

  indicatorDefinition =
    xAxis: 'year'
    yAxis: 'value'
    textField: 'text'
    fields: [{
      name: 'year'
      type: 'integer'
    }, {
      name: "value",
      type: "integer"
    }, {
      name: 'text'
      name: 'text'
    }]

  theIndicator = null

  Q.nsend(
    Indicator, 'create',
      indicatorDefinition: indicatorDefinition
  ).then( (indicator) ->
    theIndicator = indicator

    Q.nsend(
      IndicatorData, 'create'
        indicator: theIndicator
        data: indicatorData
    )
  ).then( ->
    theIndicator.getNewestHeadline()
  ).then( (mostRecentHeadline) ->

    assert.strictEqual(mostRecentHeadline.year, 2002,
      "Expected most recent headline year value to be 2002")
    assert.strictEqual(mostRecentHeadline.value, 4,
      "Expected most recent headline value to be 4")
    assert.strictEqual(mostRecentHeadline.text, "Fair",
      "Expected most recent headline text to be 'Fair'")

    done()

  ).fail((err) ->
    console.error err
    throw err
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

  ).fail((err) ->
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

    Q.nfcall(
      helpers.createIndicatorData, {
        indicator: indicatorWithData
        data: [{some: 'data'}]
      }
    )
  ).then((indicatorData) ->
    Indicator.findWhereIndicatorHasData()
  ).then((indicators) ->
    
    assert.lengthOf indicators, 1, "Expected only the one indicator with data to be returned"
    assert.strictEqual indicators[0]._id.toString(), indicatorWithData._id.toString(),
      "Expected the returned indicator to be the indicator with data"

    done()

  ).fail((err) ->
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

    Q.nfcall(
      helpers.createIndicatorData, {
        indicator: indicatorToFind
        data: [{some: 'data'}]
      }
    )
  ).then((indicatorData) ->

    Q.nfcall(
      helpers.createIndicatorData, {
        indicator: indicatorToFilterOut
        data: [{some: 'data'}]
      }
    )
  ).then((indicatorData) ->
    Indicator.findWhereIndicatorHasData(_id: indicatorToFind._id)
  ).then((indicators) ->
    
    assert.lengthOf indicators, 1, "Expected only the one indicator with data to be returned"
    assert.strictEqual indicators[0]._id.toString(), indicatorToFind._id.toString(),
      "Expected the returned indicator to be the indicator with data"

    done()

  ).fail((err) ->
    console.error err
    console.error err.stack
    throw err
  )
)

test('.calculateRecencyOfHeadline when given an indicator with a headline date
  older than the most recent data returns "Out of date"', (done) ->
  indicator = new Indicator()
  sinon.stub(indicator, 'getNewestHeadline', ->
    deferred = Q.defer()
    deferred.resolve {periodEnd: '31 Dec 2012'}
    return deferred.promise
  )

  page = new Page(parent_type: 'Indicator', headline: {periodEnd: '30 Dec 2012'})
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  indicator.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "Out of date", recencyText
    done()
  ).fail((err) ->
    console.error err
    throw err
  )
)

test('.calculateRecencyOfHeadline when given an indicator with a headline date
  equal to or newer than the most recent data returns "Up to date"', (done) ->
  indicator = new Indicator()
  sinon.stub(indicator, 'getNewestHeadline', ->
    deferred = Q.defer()
    deferred.resolve {periodEnd: '31 Dec 2012'}
    return deferred.promise
  )

  page = new Page(parent_type: 'Indicator', headline: {periodEnd: '01 Jan 2013'})
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  indicator.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "Up to date", recencyText
    done()
  ).fail((err) ->
    console.error err
    throw err
  )
)

test('.calculateRecencyOfHeadline when given an indicator with no data
  returns "No Data"', (done) ->
  indicator = new Indicator()

  page = new Page(parent_type: 'Indicator')
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  indicator.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "No Data", recencyText
    done()
  ).fail((err) ->
    console.error err
    throw err
  )
)

test('.calculateRecencyOfHeadline when given a headline with
  no periodEnd returns "Out of date"', (done) ->
  indicator = new Indicator()
  sinon.stub(indicator, 'getNewestHeadline', ->
    deferred = Q.defer()
    deferred.resolve {text: "OH HAI"}
    return deferred.promise
  )


  page = new Page(parent_type: 'Indicator', headline: {text: "Not reported on", value: "-"})
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  indicator.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "Out of date", recencyText
    done()
  ).fail((err) ->
    console.error err
    throw err
  )
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
  ).fail((err) ->
    console.error err
    throw err
  )
)

test('#calculateNarrativeRecency given an array of indicators,
  calculates their narrative recency', (done) ->
  indicator = new Indicator()
  narrativeRecency = "Up to date"
  sinon.stub(indicator, 'calculateRecencyOfHeadline', ->
    deferred = Q.defer()
    deferred.resolve narrativeRecency
    return deferred.promise
  )

  Indicator.calculateNarrativeRecency([indicator]).then( ->
    assert.strictEqual indicator.narrativeRecency, narrativeRecency,
      "Expected the narrativeRecency attribute to be populated with the narrative recency"
    done()
  ).fail((err) ->
    console.error err
    throw err
  )
)

test("#calculateBoundsForType when given an unkown type throws an appropriate error", ->
  assert.throws((->
    Indicator.calculateBoundsForType("party", [], 'fieldName'))
    ,"Don't know how to calculate the bounds of type 'party'"
  )
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

test("#roundHeadlineValues truncates decimals to 1 place", ->
  result = Indicator.roundHeadlineValues([{value: 0.123456789}])

  assert.strictEqual result[0].value, 0.1
)

test("#roundHeadlineValues when given a value which isn't a number, does nothing", ->
  result = Indicator.roundHeadlineValues([{value: 'hat'}])

  assert.strictEqual result[0].value, 'hat'
)

test(".parseDateInHeadlines on an indicator with xAxis 'date' (which is an integer),
  and no period specified, when given an integer date headline row,
  adds a 'periodEnd' attribute with the date one year in after the 'date' value", ->
  indicator = new Indicator(
    indicatorDefinition:
      xAxis: "date",
     fields: [
       {
         name: "date",
         type: "integer"
       }
     ]
  )

  headlineData = [
    date: 1997
  ]

  convertedHeadlines = indicator.parseDateInHeadlines(headlineData)
  convertedHeadline = convertedHeadlines[0]

  assert.strictEqual convertedHeadline.periodEnd, "31 Dec 1997",
    "Expected the periodEnd attribute to be calculated"
)

test(".parseDateInHeadlines on an indicator with no xAxis defined does no processing", ->
  indicator = new Indicator()

  headlineData = [
    date: 1997
  ]

  convertedHeadline = indicator.parseDateInHeadlines(headlineData)

  assert.ok _.isEqual(convertedHeadline, headlineData),
    "Expected the headline data not to be modified"
)

test(".parseDateInHeadlines on an indicator where the frequency is 'quarterly' 
  sets periodEnd to 3 months after the initial 'date'", ->

  indicator = new Indicator(
    indicatorDefinition:
      period: 'quarterly'
      xAxis: 'date'
      fields: [
        name: 'date'
      ]
  )

  headlineData = [
    date: "2013-04-01T01:00:00.000Z"
  ]

  convertedHeadlines = indicator.parseDateInHeadlines(headlineData)
  convertedHeadline = convertedHeadlines[0]

  assert.strictEqual convertedHeadline.periodEnd, "30 Jun 2013",
    "Expected the periodEnd to be 3 months from the period start"
)

test(".generateMetadataCSV returns CSV arrays containing the name, theme,
  period and data date", (done) ->
  theIndicator = theTheme = newestHeadlineStub = null

  Q.nsend(
    Theme, 'create', {
      name: 'Air Quality'
    }
  ).then( (theme) ->
    theTheme = theme

    Q.nsend(
      Indicator, 'create', {
        title: "Anne Test Indicator"
        theme: theme
        indicatorDefinition:
          period: 'quarterly'
          xAxis: 'year'
      }
    )
  ).then( (indicator) ->
    theIndicator = indicator

    newestHeadlineStub = sinon.stub(theIndicator, 'getNewestHeadline', ->
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

      assert.strictEqual titleRow[0], 'Title', "Expected the first column to be the title"
      assert.strictEqual dataRow[0], theIndicator.title,
        "Expected the title to be the title of the indicator"

      assert.strictEqual titleRow[1], 'Theme', "Expected the second column to be the theme"
      assert.strictEqual dataRow[1], theTheme.name,
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

  ).fail( (err) ->
    done(err)
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

 ).fail( (err) ->
   done(err)
 )
  
)
