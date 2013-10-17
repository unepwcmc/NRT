assert = require('chai').assert
helpers = require '../helpers'
IndicatorData = require('../../models/indicator_data').model
async = require('async')
_ = require('underscore')
Q = require 'q'

suite('Indicator Data')

test("#roundHeadlineValues truncates decimals to 3 places", ->
  result = IndicatorData.roundHeadlineValues([{value: 0.123456789}])

  assert.strictEqual result[0].value, 0.123
)

test("#roundHeadlineValues when given a value which isn't a number, does nothing", ->
  result = IndicatorData.roundHeadlineValues([{value: 'hat'}])

  assert.strictEqual result[0].value, 'hat'
)
