assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
async = require('async')
_ = require('underscore')
Q = require 'q'

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
  in decending date order', (done)->
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

test(".truncateDescription truncates descriptions over 80 characters and
  suffixes them with '...'", ->
    indicator = new Indicator(description: "Oh, yeah, the guy in the the $4,000 suit is holding the elevator for a guy who doesn't make that in three months. Come on!")

    truncatedDescription = Indicator.truncateDescription(indicator).description

    assert.lengthOf truncatedDescription, 83

    assert.strictEqual(
      "Oh, yeah, the guy in the the $4,000 suit is holding the elevator for a guy who d...",
      truncatedDescription
    )
)

test(".truncateDescription returns the indicator unchanged if there is no description", ->
    indicator = new Indicator()

    truncatedIndicator = Indicator.truncateDescription(indicator)

    assert.isUndefined truncatedIndicator.description

    assert.strictEqual(
      indicator.id
      truncatedIndicator.id
    )
)
