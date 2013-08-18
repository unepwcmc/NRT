assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
async = require('async')
_ = require('underscore')

suite('Indicator')

test('.getIndicatorData should return all indicator data for this indicator', (done) ->
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
        console.log indicator
        console.log indicatorData
        indicator.getIndicatorData((err, data) ->
          assert.ok(
            _.isEqual(data, expectedData), 
            "Expected \n#{JSON.stringify(data)} \nto equal \n#{JSON.stringify(expectedData)}"
          )
          done()
        )
  )
)