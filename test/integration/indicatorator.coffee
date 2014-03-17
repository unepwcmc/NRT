assert = require('chai').assert
sinon = require('sinon')
request = require 'request'
fs = require 'fs'

indicatorData = require('../../controllers/indicator_data')

suite('Standard Indicatorator')

test("Querying a standard indicator with source 'esri' correctly
indicatorates the data", (done) ->
  sandbox = sinon.sandbox.create()

  expectedJSON = [{
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
    }],
    "value": "9 of 13",
    "text": "BAD"
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
    }],
    "value": "10 of 20",
    "text": "GOOD"
  }]

  esriServerResponse = {
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

  indicatorDefinitions = [{
    "id": "4",
    "type": "standard",
    "source": "esri",
    "name": "Phosphate P water quality",
    "featureName": "NRT_AD_MarineWQ:3",
    "valueField": "value",
    "reduceField": "station",
    "esriConfig": {
      "serviceName": "AD_Water_quality"
      "featureServer": "hat.boat"
      "serverUrl": "/features/"
    }
  }]

  # Stubs
  requestStub = sandbox.stub(request, 'get', (options, callback) ->
    callback(null, {body: JSON.stringify(esriServerResponse)})
  )

  fsReadFileStub = sandbox.stub(fs, 'readFile', (filename, callback) ->
    callback(null, JSON.stringify(indicatorDefinitions))
  )

  assertions = (statusCode, data) ->
    try
      assert.strictEqual statusCode, 200,
        "Expected the server to respond with success, but #{statusCode}, #{data}"
      assert.deepEqual JSON.parse(data), expectedJSON,
        "Expected the application to return the correct indicatorated JSON"
    catch err
      done(err)
    finally
      sandbox.restore()

  request =
    params: id: "4"

  response =
    send: assertions

  indicatorData.query(request, response)
)
