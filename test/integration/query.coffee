assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Q = require 'q'
request = require 'request'
fs = require 'fs'

IndicatorDataController = require('../../controllers/indicators')
Indicator = require('../../models/indicator')

suite('Indicators controller')

test(".query given a request with indicator ID,
  it calls Indicator.find with that id and then calls .query on that indicator", (done)->
  req =
    params:
      id: 5

  res =
    send: (response, body) ->
      try
        assert.strictEqual response, 200,
          "Expected the request to return a 200"

        assert.strictEqual indicatorFindStub.callCount, 1,
          "Expected an indicator to be fetched"

        assert.isTrue indicatorFindStub.calledWith(req.params.id),
          "Expected Indicator.find to be called with the given ID"

        assert.strictEqual dummyIndicator.query.callCount, 1,
          "Expected 'query' to be called on the indicator returned by Indicator.find"

        done()
      catch err
        done(err)
      finally
        indicatorFindStub.restore()

  dummyIndicator =
    query: sinon.spy(->
      Q.fcall(->)
    )

  indicatorFindStub = sinon.stub(Indicator, 'find', ->
    Q.fcall( ->
      dummyIndicator
    )
  )

  IndicatorDataController.query(req, res)
)

test("Querying a standard indicator
with source: 'esri', applyRanges: false and 
 a reduceField indicatorates the data", (done) ->
  sandbox = sinon.sandbox.create()

  expectedJSON = [{
    text: "GOOD"
    value: "1 of 2",
    station: [{
      geometry: {
        x: 54.374894503000064,
        y: 24.428641001000074
      }
      OBJECTID: 1,
      station: "Palace Beach",
      periodStart: 1356998400000,
      value: 37,
      text: "GOOD",
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
    }],
    periodStart: 1356998400000
  },
  {
    text: "GOOD",
    value: "1 of 2",
    station: [{
      geometry: {
        x: 54.30470040400007,
        y: 24.465522647000057
      }
      OBJECTID: 3,
      station: "Emirates Palace Beach",
      periodStart: 1364774400000,
      value: 50,
      text: "GOOD"
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
    }],
    periodStart: 1364774400000
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
    "valueField": "value",
    "reduceField": "station",
    "applyRanges": false,
    "esriConfig": {
      "serviceName": "NRT_AD_MarineWQ:3",
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
      assert.deepEqual data, expectedJSON,
        "Expected the application to return the correct indicatorated JSON"

      done()

    catch err
      done(err)
    finally
      sandbox.restore()

  request =
    params: id: "4"

  response =
    send: assertions

  IndicatorDataController.query(request, response)
)
