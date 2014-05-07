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
      fields: []
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

        indicatorDataIdMatch = "\"_id\":\"#{indicatorData.id}\""
        indicatorIdMatch = "\"indicator\":\"#{indicator.id}\""
        dataMatch = "\"data\":\\[null\\]"
        assert.match body, new RegExp(".*Successfully updated indicator.*")
        assert.match body, new RegExp(".*#{indicatorDataIdMatch}.*")
        assert.match body, new RegExp(".*#{indicatorIdMatch}.*")
        assert.match body, new RegExp(".*#{dataMatch}.*")

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

        indicatorDataIdMatch = "\"_id\":\"#{indicatorData.id}\""
        indicatorIdMatch = "\"indicator\":\"#{indicator.id}\""
        dataMatch = "\"data\":\\[null\\]"
        assert.match body, new RegExp(".*Successfully updated indicator.*")
        assert.match body, new RegExp(".*#{indicatorDataIdMatch}.*")
        assert.match body, new RegExp(".*#{indicatorIdMatch}.*")
        assert.match body, new RegExp(".*#{dataMatch}.*")

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
