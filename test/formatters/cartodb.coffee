assert = require('chai').assert
sinon = require('sinon')
Q = require('q')
_ = require('underscore')

CartoDBFormatter = require('../../formatters/cartodb')

suite('CartoDB Formatter')

test('CartoDB query result, it formats it correctly', ->
  rawData = [
    {
      "field_1": "Theme",
      "field_2": "Indicator",
      "field_3": "SubIndicator",
      "field_4": "1997",
      "field_5": "1998"
    }, {
      'field_1': 'Air quality',
      'field_2': 'CO2 level',
      'field_3': '',
      'field_4': '0%',
      'field_5': '80%'
    }
  ]

  expectedResult = [
    {periodStart: 852076800000, value: 0},
    {periodStart: 883612800000, value: 0.80}
  ]

  actualResult = CartoDBFormatter(rawData)

  assert.deepEqual actualResult, expectedResult
)
