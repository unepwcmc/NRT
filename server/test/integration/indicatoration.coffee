assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
Q = require('q')

sinon = require('sinon')
passportStub = require 'passport-stub'

Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model

suite('Indicatoration')

test("calling /admin/updateIndicatorData/{indicatorId}
  returns updated indicatorData", (done) ->
  indicator = new Indicator(
    type: "standard"
    indicatorDefinition: {
      fields: [
        {
          name: "year"
          type: "integer"
          source: {
            name: "periodStart"
            type: "epoch"
          }
        }, {
          name: "value"
          type: "decimal"
          source: {
            name: "value"
            type: "decimal"
          }
        }
      ]
    }
    indicatorationConfig: {
      source: "esri"
      esriConfig: {
        serverUrl: "http://nrtstest.ead.ae/ka/rest/services"
        serviceName: "NRT_AD_AirQuality"
        featureServer: 1
      }
      range: [
        {threshold: 0.35, text: "Excellent"},
        {threshold: 0.15, text: "Good"},
        {threshold: 0, text: "Bad"}
      ]
    }
  )

  esriResponse = {
    "features": [
      {
        "geometry": {
          "x": 55.342883000000029,
          "y": 24.466660000000047
        },
        "attributes": {
          "periodStart": 1364774400000,
          "value": 0.29999999999999999,
          "station": "Sweihan"
        }
      }, {
        "geometry": {
          "x": 65.342883000000029,
          "y": 34.466660000000047
        },
        "attributes": {
          "periodStart": 1362774400000,
          "value": 0.1300000000000000,
          "station": "Redmond"
        }
      }
    ]
  }

  requestGetStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, {body: JSON.stringify(esriResponse)})
  )

  Q.nsend(
    indicator, 'save'
  ).spread( (savedIndicator) ->
    indicator = savedIndicator
    Q.nfcall(
      request.post, {
        url: helpers.appurl("/admin/updateIndicatorData/#{indicator.id}")
      }
    )
  ).spread((res, body) ->
    Q.nsend(
      IndicatorData.findOne(indicator: indicator.id),
      'exec'
    ).then((indicatorData) ->
      try
        assert.equal res.statusCode, 201,
          "Expected response to succeed, but got error:
          #{body}"

        expectedBody = {
          _id: indicatorData.id,
          indicator: indicator.id,
          data:[{
            text: "Good"
            value: 0.3
            year: 2013
          }, {
            text: "Bad"
            value: 0.13
            year: 2013
          }]
        }

        assert.deepEqual JSON.parse(body), expectedBody,
          "Expected the response body to contain the correct data"

        done()
      catch e
        done(e)
      finally
        requestGetStub.restore()
    )
  ).fail((err)->
    requestGetStub.restore()
    return done(err)
  )
)


test("calling /admin/updateIndicatorData/{indicatorId}
  correctly queries an indicator with a world bank source", (done) ->
  indicator = new Indicator(
    type: "standard"
    shortName: "Forest Area"
    indicatorDefinition: {
      fields: []
    }
    indicatorationConfig: {
      source: "worldBank"
      worldBankConfig: {
        countryCode: 'MU'
        indicatorCode: 'AG.LND.FRST.ZS'
      }
      range: [
        {threshold: 0.35, text: "Excellent"},
        {threshold: 0.15, text: "Good"},
        {threshold: 0, text: "Bad"}
      ]
    }
  )

  worldBankResponse = [
    {},
    [
      {
        "indicator": {
          "id": "AG.LND.FRST.ZS",
          "value": "Forest area (% of land area)"
        },
        "country": {
          "id": "MU",
          "value": "Mauritius"
        },
        "value": "17.2512315270936",
        "decimal": "1",
        "date": "1969"
      }
    ]
  ]

  requestGetStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, {body: JSON.stringify(worldBankResponse)})
  )

  Q.nsend(
    indicator, 'save'
  ).spread( (savedIndicator) ->
    indicator = savedIndicator
    Q.nfcall(
      request.post, {
        url: helpers.appurl("/admin/updateIndicatorData/#{indicator.id}")
      }
    )
  ).spread((res, body) ->
    Q.nsend(
      IndicatorData.findOne(indicator: indicator.id),
      'exec'
    ).then((indicatorData) ->
      try
        assert.equal res.statusCode, 201,
          "Expected response to succeed, but got error:
          #{body}"

        expectedBody = {
          _id: indicatorData.id
          indicator: indicator.id
          data: []
        }

        assert.deepEqual JSON.parse(body), expectedBody,
          "Expected the response body to contain the correct data"

        done()
      catch e
        done(e)
      finally
        requestGetStub.restore()
    )
  ).fail((err)->
    requestGetStub.restore()
    return done(err)
  )
)
