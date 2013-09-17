assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
async = require('async')
_ = require('underscore')

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
      externalId: 14
  )
  indicatorData = new IndicatorData(
    externalId: 14, data: data
  )

  async.parallel([
        (cb) -> indicator.save(cb)
      ,
        (cb) -> indicatorData.save(cb)
    ], (err, results) ->
      if err?
        console.error err
      else
        indicator.getIndicatorDataForCSV( (err, indicatorData) ->
          assert.ok(
            _.isEqual(indicatorData, expectedData),
            "Expected \n#{JSON.stringify(indicatorData)} \nto equal \n#{JSON.stringify(expectedData)}"
          )
          done()
        )
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
      externalId: 14
  )
  indicatorData = new IndicatorData(
    externalId: 14, data: data
  )

  filters =
    value:
      min: '4'

  async.parallel([
        (cb) -> indicator.save(cb)
      ,
        (cb) -> indicatorData.save(cb)
    ], (err, results) ->
      if err?
        console.error err
      else
        indicator.getIndicatorDataForCSV( filters, (err, indicatorData) ->
          assert.ok(
            _.isEqual(indicatorData, expectedData),
            "Expected \n#{JSON.stringify(indicatorData)} \nto equal \n#{JSON.stringify(expectedData)}"
          )
          done()
        )
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

  indicator = new Indicator(
    indicatorDefinition:
      externalId: 14
  )
  indicatorData = new IndicatorData(
    externalId: 14, data: expectedData
  )

  async.parallel([
        (cb) -> indicator.save(cb)
      ,
        (cb) -> indicatorData.save(cb)
    ], (err, results) ->
      if err?
        console.error err
      else
        indicator.getIndicatorData((err, data) ->
          assert.ok(
            _.isEqual(data, expectedData),
            "Expected \n#{JSON.stringify(data)} \nto equal \n#{JSON.stringify(expectedData)}"
          )
          done()
        )
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

  indicator = new Indicator(
    indicatorDefinition:
      externalId: 14
  )
  indicatorData = new IndicatorData(
    externalId: 14, data: fullData
  )

  filters =
    value:
      min: '4'

  async.parallel([
        (cb) -> indicator.save(cb)
      ,
        (cb) -> indicatorData.save(cb)
    ], (err, results) ->
      if err?
        console.error err
      else
        indicator.getIndicatorData(filters, (err, data) ->
          assert.ok(
            _.isEqual(data, expectedFilteredData),
            "Expected \n#{JSON.stringify(data)} \nto equal \n#{JSON.stringify(expectedFilteredData)}"
          )
          done()
        )
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
      externalId: 14
      fields: [{
        name: 'year'
        type: 'integer'
      }, {
        name: "value",
        type: "integer"
      }]
  )
  indicatorData = new IndicatorData(
    externalId: 14, data: indicatorData
  )

  async.parallel([
        (cb) -> indicator.save(cb)
      ,
        (cb) -> indicatorData.save(cb)
    ], (err, results) ->
      if err?
        console.error err
      else
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
  )
)

test('.create with nested section', (done) ->
  indicator_attributes =
    sections: [{
      title: 'dat title'
    }]

  indicator = new Indicator(indicator_attributes)
  indicator.save((err, indicator) ->
    if err?
      console.error err
      throw 'indicator saving failed'
      done()

    assert.strictEqual indicator.title, indicator_attributes.title
    assert.strictEqual indicator.sections[0].title, indicator_attributes.sections[0].title
    done()
  )
)
