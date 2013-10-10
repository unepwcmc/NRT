assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
Q = require('q')
request = require 'request'
sinon = require 'sinon'
_ = require('underscore')

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

test('.convertResponseToIndicatorData takes data from remote server and
  prepares for writing to database', (done)->
  responseData = {
    features: [
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
  }

  helpers.createIndicatorModels([{}])
  .then( (indicators) ->
    indicator = indicators[0]

    expectedIndicatorData = {
      indicator: indicator._id
      data: [
          periodStart: 1325376000000
          value: "0.29390622"
          text: "Test"
        ,
          periodStart: 1356998400000
          value: "0.2278165"
          text: "Test"
      ]
    }

    convertedData = indicator.convertResponseToIndicatorData(responseData)

    assert.ok(
      _.isEqual(convertedData, expectedIndicatorData),
      "Expected converted data:\n
      #{JSON.stringify(convertedData)}\n
        to look like expected indicator data:\n
      #{JSON.stringify(expectedIndicatorData)}"
    )

    done()

  ).fail((err) ->
    console.error err
    throw err
  )
)

test(".validateIndicatorDataFields given the correct fields returns no errors", ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        name: 'year'
        type: 'integer'
      }, {
        name: 'value'
        type: 'integer'
      }]
  )

  indicatorData = {
    indicator: indicator._id
    data: [{
      year: 1992
      value: "0.29390622"
      text: "Test"
    }]
  }

  assert.ok indicator.validateIndicatorDataFields(indicatorData),
    "Expected validateIndicatorData to return true without error"
)

test(".validateIndicatorDataFields when missing fields returns an error", ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        name: 'year'
        type: 'integer'
      }, {
        name: 'value'
        type: 'integer'
      }]
  )

  indicatorData = {
    indicator: indicator._id
    data: [{
      year: 1992
      text: "Test"
    }]
  }

  assert.throws( (->
      indicator.validateIndicatorDataFields(indicatorData)
    ), "Couldn't find 'value' attribute in data"
  )
)

test('.convertIndicatorDataFields when given valid epoch to integer field translation
  it converts the field to the correct name and type', ->

  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        source:
          name: 'periodStart'
          type: 'epoch'
        name: 'year'
        type: 'integer'
      }]
  )

  untranslatedData = {
    indicator: indicator._id
    data: [
      periodStart: 1325376000000
    ]
  }

  expectedData = {
    indicator: indicator._id
    data: [
      year: 2012
    ]
  }

  convertedData = indicator.convertIndicatorDataFields(untranslatedData)
  assert.ok(
    _.isEqual(convertedData, expectedData),
    "Expected converted data:\n
    #{JSON.stringify(convertedData)}\n
      to look like expected indicator data:\n
    #{JSON.stringify(expectedData)}"
  )
  
)

test('.convertSourceValueToInternalValue when given two values of the same 
  type it returns same value', ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        source:
          name: 'periodStart'
          type: 'integer'
        name: 'year'
        type: 'integer'
      }]
  )
  result = indicator.convertSourceValueToInternalValue('periodStart', 5)
  assert.strictEqual result, 5, 
    "Expected conversion not to modify source value"
)
test(".convertSourceValueToInternalValue when given a type conversion which
  doesn't exist, it throws appropriate error", ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        source:
          name: 'periodStart'
          type: 'apples'
        name: 'year'
        type: 'oranges'
      }]
  )

  assert.throws (->
    indicator.convertSourceValueToInternalValue('periodStart', 5)
  ), "Don't know how to convert 'apples' to 'oranges' for field 'periodStart'"
    
)
