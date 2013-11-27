assert = require('chai').assert
sinon = require('sinon')

StandardIndicatorator = require '../indicatorators/standard_indicatorator'

suite('Standard indicatorator')

test('.indicatorate throws an error when no data is passed in', ->
  indicatorator = new StandardIndicatorator('ede')

  assert.throws indicatorator.indicatorate(), "No data to indicatorate"
)

test('.indicatorate adds the correct indicator text to each data point', ->
  indicatorator = new StandardIndicatorator('ede')

  calculateTextStub = sinon.stub(indicatorator, 'calculateIndicatorText', -> 'Super Awesome')

  indicatorator.indicatorDefinition =
    valueField: 'value'
    ranges: [
      {"minValue": 0, "message": "Super Awesome"}
    ]

  rows = [
    {"value":6,"year":1981}
  ]

  results = indicatorator.indicatorate(rows)

  assert.lengthOf results, 1, "Expected no rows to be removed"

  result = results[0]
  assert.strictEqual result.text, 'Super Awesome',
    "Expected the text value to be set to 'Super Awesome'"

  calculateTextStub.restore()
)

test(".calculateIndicatorText returns 'Value outside expected range' if
  no range exists for the value specified", ->
  indicatorator = new StandardIndicatorator('ede')
  indicatorator.indicatorDefinition =
    ranges: [
      {"minValue": 10, "message": "Hey, cool!"}
    ]

  assert.strictEqual indicatorator.calculateIndicatorText(9),
    "Error: Value 9 outside expected range"
)

test('.calculateIndicatorText calculates correct text value from ranges', ->
  indicatorator = new StandardIndicatorator('ede')
  indicatorator.indicatorDefinition =
    ranges: [
      {"minValue": 10, "message": "Hey, cool!"}
    ]

  assert.strictEqual indicatorator.calculateIndicatorText(11), "Hey, cool!"
)
