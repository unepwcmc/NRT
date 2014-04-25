assert = require('chai').assert
sinon = require('sinon')

RangeApplicator = require '../../lib/range_applicator'
SubIndicator = require '../../lib/subindicatorator'

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

  rangedData = RangeApplicator.applyRanges(data, ranges)

  firstRow = rangedData[0]
  assert.isDefined firstRow,
    "Expected there to be a first row of results"

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

test(".applyRanges given standard data with subindicators and a range
adds a 'text' to both the indicator and subindicators", ->
  data = [{
    periodStart: 1356998400000, value: 0.1, subIndicator: [
      {subIndicator: 'Kuwait', value: 0, periodStart: 1356998400000},
      {subIndicator: 'BP', value: 0.2, periodStart: 1356998400000}
    ]
  }, {
    periodStart: 1357257600000, value: 0.80, subIndicator: [
      {subIndicator: 'Kuwait', value: 0.8, periodStart: 1357257600000},
      {subIndicator: 'BP', value: 0.8, periodStart: 1357257600000}
    ]
  }]

  ranges = [
    {"minValue": 0.7, "message": "Excellent"},
    {"minValue": 0.2, "message": "Moderate"},
    {"minValue": 0, "message": "Poor"}
  ]

  rangedData = RangeApplicator.applyRanges(data, ranges)

  firstRow = rangedData[0]
  assert.property firstRow, 'text',
    "Expected a text property to be added"
  assert.strictEqual firstRow.text, 'Poor',
    "Expected the text property the correct value from the range"

  subIndicator = firstRow.subIndicator[0]
  assert.property subIndicator, 'text',
    "Expected a text property to be added to the sub indicators"
  assert.strictEqual subIndicator.text, 'Poor',
    "Expected the sub indicators to have the correct text value"
  subIndicator = firstRow.subIndicator[1]
  assert.property subIndicator, 'text',
    "Expected a text property to be added to the sub indicators"
  assert.strictEqual subIndicator.text, 'Moderate',
    "Expected the sub indicators to have the correct text value"

  lastRow = rangedData[1]
  assert.property lastRow, 'text',
    "Expected a text property to be added"
  assert.strictEqual lastRow.text, 'Excellent',
    "Expected the text property the correct value from the range"

  subIndicator = lastRow.subIndicator[0]
  assert.property subIndicator, 'text',
    "Expected a text property to be added to the sub indicators"
  assert.strictEqual subIndicator.text, 'Excellent',
    "Expected the sub indicators to have the correct text value"
  subIndicator = lastRow.subIndicator[1]
  assert.property subIndicator, 'text',
    "Expected a text property to be added to the sub indicators"
  assert.strictEqual subIndicator.text, 'Excellent',
    "Expected the sub indicators to have the correct text value"
)
