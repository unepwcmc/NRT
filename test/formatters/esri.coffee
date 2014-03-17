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
    geometry: {
      x: 54.374894503000064,
      y: 24.428641001000074
    },
    OBJECTID: 1,
    station: "Palace Beach",
    periodStart: 1356998400000,
    value: 37,
    text: "GOOD"
  }, {
    geometry: {
        x: 54.30470040400007,
        y: 24.465522647000057
    },
    OBJECTID: 3,
    station: "Emirates Palace Beach",
    periodStart: 1364774400000,
    value: 50,
    text: "GOOD"
  }, {
    geometry: {
        x: 54.30470040400007,
        y: 24.465522647000057
    },
    OBJECTID: 15,
    station: "Emirates Palace Beach",
    periodStart: 1356998400000,
    value: 160,
    text: "BAD"
  }, {
    geometry: {
        x: 54.374894503000064,
        y: 24.428641001000074
    },
    OBJECTID: 25,
    station: "Palace Beach",
    periodStart: 1364774400000,
    value: 400,
    text: "BAD"
  }]

  actualResult = EsriFormatter(rawData)

  assert.deepEqual actualResult, expectedResult
)

test("If the data is missing a 'periodStart', it throws an appropriate error")

test("If the data doesn't have a feature attribute, it throws an appropriate error")
