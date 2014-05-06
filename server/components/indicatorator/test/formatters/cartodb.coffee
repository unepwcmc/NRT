assert = require('chai').assert

CartoDBFormatter = require('../../formatters/cartodb')

suite('CartoDB Formatter')

test('CartoDB query result, it formats it correctly', ->
  rawData = [
    {
      "field_1": "Theme",
      "field_2": "Indicator",
      "field_3": "SubIndicator",
      "field_4": "1997",
      "field_5": "1998",
      "the_geom": null,
      "cartodb_id": 1,
      "created_at": '2014-02-07T09:26:51Z',
      "updated_at": '2014-02-07T09:26:51Z',
      "the_geom_webmercator": null
    }, {
      'field_1': 'Air quality',
      'field_2': 'CO2 level',
      'field_3': '',
      'field_4': '0%',
      'field_5': '80%',
      "the_geom": null,
      "cartodb_id": 2,
      "created_at": '2014-02-07T09:26:51Z',
      "updated_at": '2014-02-07T09:26:51Z',
      "the_geom_webmercator": null
    }
  ]

  expectedResult = [
    {periodStart: "1997", value: "0%"},
    {periodStart: "1998", value: "80%"}
  ]

  actualResult = CartoDBFormatter(rawData)

  assert.deepEqual actualResult, expectedResult
)
