assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
async = require('async')
_ = require('underscore')

suite('Indicator')

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
      enviroportalId: 14
  )
  indicatorData = new IndicatorData(
    enviroportalId: 14, data: expectedData
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
      enviroportalId: 14
  )
  indicatorData = new IndicatorData(
    enviroportalId: 14, data: fullData
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
      enviroportalId: 14
      fields: [{
        name: 'year'
        type: 'integer'
      }, {
        name: "value",
        type: "integer"
      }]
  )
  indicatorData = new IndicatorData(
    enviroportalId: 14, data: indicatorData
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
