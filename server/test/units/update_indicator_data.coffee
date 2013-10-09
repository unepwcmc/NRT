assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
Q = require('q')
request = require 'request'
sinon = require 'sinon'

suite('Update Indicator Mixin')

test('.getUpdateUrl on an indicator with a valid serviceName and featureServer
 it returns a valid url', ->
  indicator = new Indicator
    indicatorDefinition:
      serviceName:  'NRT_AD_ProtectedArea'
      featureServer: 2
  expectedUrl = 'http://196.218.36.14/ka/rest/services/NRT_AD_ProtectedArea/FeatureServer/2/query'
  url = indicator.getUpdateUrl()

  assert.strictEqual url, expectedUrl
)

test('.queryIndicatorData queries the remote server for indicator data', ->
  indicator = new Indicator
    indicatorDefinition:
      serviceName:  'NRT_AD_ProtectedArea'
      featureServer: 2

  serverResponseData = [
    attributes:
      OBJECTID: 1
      periodStart: 1325376000000
      value: "0.29390622"
      text: "Test"
  ,
    attributes:
      OBJECTID: 2
      periodStart: 1356998400000
      value: "0.2278165"
      text: "Test"
  ]

  requestStub = sinon.stub(request, 'get', (options, callback)->
    assert.strictEqual options.url, indicator.getUpdateUrl()
    callback(null, {
      body: JSON.stringify(serverResponseData)
    }))

  indicator.queryIndicatorData().then( (response) ->
    assert.strictEqual JSON.parse(response.body), serverResponseData
    done()
  ).fail( (err) ->
    console.error err
    throw err
  )

)
