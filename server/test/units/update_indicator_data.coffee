assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
Q = require('q')
request = require 'request'
sinon = require 'sinon'
_ = require('underscore')

suite('Update Indicator Mixin')

test('.getUpdateUrl on indicator with no type throws an appropriate error', ->
  indicator = new Indicator()

  assert.throws((->
    indicator.getUpdateUrl()
  ), "Couldn't find a url builder for indicator.type: 'undefined'")
)

test('.getUpdateUrl on an environmental indicator with a valid serviceName and featureServer
 it returns a valid url', ->
  indicator = new Indicator
    type: 'environmental'
    indicatorDefinition:
      serviceName:  'NRT_AD_ProtectedArea'
      featureServer: 2
  expectedUrl = 'http://196.218.36.14/ka/rest/services/NRT_AD_ProtectedArea/FeatureServer/2/query'
  url = indicator.getUpdateUrl()

  assert.strictEqual url, expectedUrl
)

test('.getUpdateUrl on an environmental indicator with no serviceName and featureServer
 it throws an error', ->
  indicator = new Indicator(
    type: 'environmental'
  )

  assert.throws (-> indicator.getUpdateUrl()), "Cannot generate update URL, environmental indicator has no serviceName or featureServer in its indicator definition"
)

test('.getUpdateUrl on a worldBank indicator with a valid apiUrl and apiIndicatorName', ->
  indicator = new Indicator
    type: 'worldBank'
    indicatorDefinition:
      apiUrl: "http://api.worldbank.org/countries/ARE"
      apiIndicatorName: "NY.ADJ.DCO2.GN.ZS"

  expectedUrl = "http://api.worldbank.org/countries/ARE/NY.ADJ.DCO2.GN.ZS"
  url = indicator.getUpdateUrl()

  assert.strictEqual url, expectedUrl
)

test('.getUpdateUrl on a worldBank indicator with missing apiUrl and apiIndicatorName
 it throws an error', ->
  indicator = new Indicator(type: 'worldBank')

  assert.throws (-> indicator.getUpdateUrl()), "Cannot generate update URL, indicator has no apiUrl or apiIndicatorName in its indicator definition"
)

test('.queryIndicatorData queries the remote server for indicator data', (done) ->
  indicator = new Indicator
    type: 'environmental'
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
    assert.isDefined options.qs, "Expected query string parameters to be defined"

    callback(null, {
      body: serverResponseData
    }))

  indicator.queryIndicatorData().then( (response) ->
    assert.ok(
      _.isEqual(response.body, serverResponseData),
      "Expected responseBody:\n
      #{response.body}\n
        to look like expected server response data:\n
      #{serverResponseData}"
    )

    done()
  ).fail( (err) ->
    console.error err
    throw err
  )

)

test('.convertResponseToIndicatorData on indicator with no type throws an appropriate error', ->
  indicator = new Indicator()

  assert.throws((->
    indicator.convertResponseToIndicatorData()
  ), "Couldn't find a data parser for indicator.type: 'undefined'")
)

test('.convertResponseToIndicatorData for an environmental indicator
  takes data from remote server and prepares for writing to database', (done)->
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

  helpers.createIndicatorModels([{
    type: 'environmental'
  }]).then( (indicators) ->
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

test('.convertResponseToIndicatorData on an environmental indicator
  when given a garbage response it throws an error', ->
  indicator = new Indicator(
    type: 'environmental'
  )

  garbageData = {hats: 'boats'}
  assert.throws(
    (->
      indicator.convertResponseToIndicatorData(garbageData)
    ), "Can't convert poorly formed indicator data reponse:\n#{
          JSON.stringify(garbageData)
        }\n expected response to contains 'features' attribute which is an array"
  )
)

test('.convertResponseToIndicatorData for a worldBank indicator
  takes data from remote server and prepares for writing to database', (done)->
  responseData = [
    {
      "page": 1
    },
    [
      {
        "indicator": {
          "id": "NY.ADJ.DCO2.GN.ZS",
          "value": "Adjusted savings: carbon dioxide damage (% of GNI)"
        },
        "value": null,
        "decimal": "1",
        "date": "1961"
      }
    ]
  ]

  helpers.createIndicatorModels([{
    type: 'worldBank'
  }]).then( (indicators) ->
    indicator = indicators[0]

    expectedIndicatorData = {
      indicator: indicator._id
      data: [
        {
          "indicator": {
            "id": "NY.ADJ.DCO2.GN.ZS",
            "value": "Adjusted savings: carbon dioxide damage (% of GNI)"
          },
          "value": null,
          "decimal": "1",
          "date": "1961"
        }
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

test('.convertResponseToIndicatorData on a worldBank indicator
  when given a garbage response it throws an error', ->
  indicator = new Indicator(
    type: 'worldBank'
  )

  garbageData = {hats: 'boats'}
  assert.throws(
    (->
      indicator.convertResponseToIndicatorData(garbageData)
    ), "Can't convert poorly formed indicator data reponse:\n#{
          JSON.stringify(garbageData)
        }\n expected response to be a world bank api response;#{
      } an array with a data array as the second element"
  )
)

test(".validateIndicatorDataFields given the correct fields returns no errors", ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        source:
          name: 'periodStart'
          type: 'epoch'
        name: 'year'
        type: 'integer'
      }, {
        source:
          name: 'value'
          type: 'integer'
        name: 'value'
        type: 'integer'
      }]
  )

  indicatorData = {
    indicator: indicator._id
    data: [{
      periodStart: 19922332000000
      value: "0.29390622"
      text: "Test"
    }]
  }

  assert.ok indicator.validateIndicatorDataFields(indicatorData),
    "Expected validateIndicatorData to return true without error"
)

test(".validateIndicatorDataFields when a field is present but null returns no errors", ->
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

  indicatorData = {
    indicator: indicator._id
    data: [{
      periodStart: null
    }]
  }

  assert.ok indicator.validateIndicatorDataFields(indicatorData),
    "Expected validateIndicatorData to return true without error"
)

test(".validateIndicatorDataFields when missing fields returns an error", ->
  indicator = new Indicator(
    title: "Protected Areas"
    indicatorDefinition:
      fields: [{
        source:
          name: 'periodStart'
          type: 'epoch'
        name: 'year'
        type: 'integer'
      }, {
        source:
          name: 'value'
          type: 'integer'
        name: 'value'
        type: 'integer'
      }]
  )

  indicatorData = {
    indicator: indicator._id
    data: [{
      periodStart: 192340000
      text: "Test"
    }]
  }

  assert.throws( (->
      indicator.validateIndicatorDataFields(indicatorData)
    ), new RegExp("Couldn't find source attribute \'value\' in data")
  )
)

test(".validateIndicatorDataFields on an indicator with fields with no source
 throws an appropriate error ", ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [
        name: 'hats'
        type: 'float'
      ]
  )

  assert.throws((->
      indicator.validateIndicatorDataFields({data: []})
    ), new RegExp(".*Indicator field definition doesn't include a source attribute.*")
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

test('.translateRow includes fields with definitions and skips those without', ->
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

  row = {
    periodStart: 12343242300000
    fresh: true
  }

  translatedRow = indicator.translateRow(row)

  assert.property translatedRow, 'year',
    "Expected periodStart property to be included in translatedRow"
  assert.notProperty translatedRow, 'fresh',
    "Expected periodStart property to not be included in translatedRow"
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

test(".replaceIndicatorData when called on an  indicator where indicator data
  already exists,
  it replaces the existing data with the new given data", (done) ->

  indicator = oldIndicatorData = null
  newIndicatorData = [{
    year: 2013
  }]

  helpers.createIndicatorModels(
    [{}]
  ).then( (indicators) ->
    indicator = indicators[0]

    # populate existing indicator data
    Q.nfcall(
      helpers.createIndicatorData, {
        indicator: indicator
        data: [old: 'data']
      }
    )
  ).then( (indicatorData) ->
    oldIndicatorData = indicatorData

    # Replace existing data with new data
    indicator.replaceIndicatorData({
      indicator: indicator
      data: newIndicatorData
    })
  ).then( (replacedIndicatorData) ->
    assert.strictEqual replacedIndicatorData.id, oldIndicatorData.id,
      "Expected updated indicator.id to be the same as the original record"

    Q.nsend(
      indicator, 'getIndicatorData'
    )
  ).then( (retrievedIndicatorData) ->

    assert.ok(
      _.isEqual(retrievedIndicatorData, newIndicatorData),
      "Expected indicator data:\n
      #{JSON.stringify(retrievedIndicatorData)}\n
        to have been updated to be new indicator data:\n
      #{JSON.stringify(newIndicatorData)}"
    )
    done()

  ).fail((err) ->
    console.error err
    throw err
  )
  
)
