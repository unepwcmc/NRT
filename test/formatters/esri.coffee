assert = require('chai').assert
sinon = require('sinon')

Indicator = require('../../models/indicator')
EsriFormatter = require('../../formatters/esri')

suite('Esri Formatter')

test('Esri query result, it formats it correctly', ->
  rawData = {
    "features": [
      {
          "geometry": {
              "x": 54.374894503000064,
              "y": 24.428641001000074
          },
          "attributes": {
              "OBJECTID": 1,
              "station": "Palace Beach",
              "periodStart": 1356998400000,
              "value": 37,
              "text": "GOOD"
          }
      },
      {
          "geometry": {
              "x": 54.30470040400007,
              "y": 24.465522647000057
          },
          "attributes": {
              "OBJECTID": 3,
              "station": "Emirates Palace Beach",
              "periodStart": 1364774400000,
              "value": 50,
              "text": "GOOD"
          }
      },
      {
          "geometry": {
              "x": 54.30470040400007,
              "y": 24.465522647000057
          },
          "attributes": {
              "OBJECTID": 15,
              "station": "Emirates Palace Beach",
              "periodStart": 1356998400000,
              "value": 160,
              "text": "BAD"
          }
      },
      {
          "geometry": {
              "x": 54.374894503000064,
              "y": 24.428641001000074
          },
          "attributes": {
              "OBJECTID": 25,
              "station": "Palace Beach",
              "periodStart": 1364774400000,
              "value": 400,
              "text": "BAD"
          }
      }
    ]
  }

  expectedResult = [{
    "date": "2013-01-01T00:00:00.000Z",
    "station": [{
      "text": "GOOD",
      "value": 37,
      "periodStart": 1356998400000,
      "station": "Palace Beach",
      "geometry": {
        "y": 24.428641001000074,
        "x": 54.374894503000064
      }
    }]
  },
  {
    "date": "2013-04-01T00:00:00.000Z",
    "station": [{
      "text": "GOOD",
      "value": 50,
      "periodStart": 1364774400000,
      "station": "Emirates Palace Beach",
      "geometry": {
        "y": 24.465522647000057,
        "x": 54.30470040400007
      }
    }]
  }]

  indicator = new Indicator(
    reduceField: 'station'
  )

  actualResult = EsriFormatter(rawData, indicator)

  assert.deepEqual actualResult, expectedResult
)
