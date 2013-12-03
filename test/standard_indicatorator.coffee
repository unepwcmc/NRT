assert = require('chai').assert
sinon = require('sinon')

StandardIndicatorator = require '../indicatorators/standard_indicatorator'

suite('Standard indicatorator')

test(".applyRanges given standard data and a range
adds a 'text' attribute with the correct values based on the range", ->
  data = [
    {periodStart: 2012, value: 501},
    {periodStart: 2013, value: 400}
  ]

  ranges = [
    {"minValue": 1000, "message": "Excellent"},
    {"minValue": 500, "message": "Moderate"},
    {"minValue": 0, "message": "Poor"}
  ]

  rangedData = StandardIndicatorator.applyRanges(data, ranges)

  firstRow = rangedData[0]
  assert.property firstRow, 'text',
    "Expected a text property to be added"
  assert.strictEqual firstRow.text, 'Moderate',
    "Expected the text property the correct value from the range"

  lastRow = rangedData[1]
  assert.property lastRow, 'text',
    "Expected a text property to be added"
  assert.strictEqual lastRow.text, 'Poor',
    "Expected the text property the correct value from the range"
)
