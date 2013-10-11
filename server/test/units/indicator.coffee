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

test('.calculateIndicatorDataBounds should return the upper and lower bounds of data', (done) ->
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
