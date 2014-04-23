assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
Q = require('q')
request = require 'request'
sinon = require 'sinon'
_ = require('underscore')

suite('Update Indicator Mixin')

test('.convertResponseToIndicatorData puts the indicator data into
  the format of the indicator_data table', (done)->
  responseData = [{"year": 1998, "value": 400}]

  helpers.createIndicatorModels([{
    type: 'standard'
  }]).then( (indicators) ->
    indicator = indicators[0]

    expectedIndicatorData = {
      indicator: indicator._id
      data: [
        {
          "value": 400,
          "year": 1998
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

  ).fail(done)
)

test('.convertResponseToIndicatorData when given a garbage response
  throws an error', ->
  indicator = new Indicator(
    type: 'standard'
  )

  garbageData = {hats: 'boats'}
  assert.throws(
    (->
      indicator.convertResponseToIndicatorData(garbageData)
    ), "Can't convert poorly formed indicator data reponse:\n#{
          JSON.stringify(garbageData)
        }\n expected response to be an array"
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

test(".convertSourceValueToInternalValue when given a decimalPercentage to 
  integer conversion, it multiplies by 100", ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        source:
          name: 'value'
          type: 'decimalPercentage'
        name: 'value'
        type: 'integer'
      }]
  )

  result = indicator.convertSourceValueToInternalValue('value', 0.504)
  assert.strictEqual result, 50.4,
    "Expected value to be mutliplied by 100"
    
)

test(".convertSourceValueToInternalValue when given an epoch to 
  date conversion, it converts the value correctly", ->
  indicator = new Indicator(
    indicatorDefinition:
      fields: [{
        source:
          name: 'value'
          type: 'epoch'
        name: 'value'
        type: 'date'
      }]
  )

  result = indicator.convertSourceValueToInternalValue('value', 1325376000000)

  assert.ok typeof result.getMonth is 'function',
    "Expected the result to be a date"
  assert.strictEqual result.getMonth(), 0,
    "Expected the date to be in October"
  assert.strictEqual result.getFullYear(), 2012,
    "Expected the date to be in 2013"
    
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

test(".updateIndicatorData queries IndicatoratorIndicator and calls
  .replaceIndicatorData with the converted result", (done) ->
  IndicatoratorIndicator = require('../../components/indicatorator/models/indicator.coffee')

  fakeIndicator = {
    query: sinon.spy(->
      Q.fcall(->
        []
      )
    )
  }

  indicatoratorIndicatorFindSpy = sinon.stub(IndicatoratorIndicator, 'find', (id) ->
    Q.fcall(->
      fakeIndicator
    )
  )

  indicatoratorId = 5
  indicator = new Indicator(
    indicatorDefinition:
      indicatoratorId: indicatoratorId
      fields: []
  )

  indicator.updateIndicatorData().then(->
    try
      assert.strictEqual indicatoratorIndicatorFindSpy.callCount, 1,
        "Expected IndicatoratorIndicator.find to be called"
      assert.isTrue indicatoratorIndicatorFindSpy.calledWith(indicatoratorId),
        "Expected IndicatoratorIndicator.find to be called with the indicatoratorId"
      assert.strictEqual fakeIndicator.query.callCount, 1,
        "Expected IndicatoratorIndicator.query to be called"

      done()
    catch err
      done(err)
    finally
      indicatoratorIndicatorFindSpy.restore()
  ).fail((err)->
    indicatoratorIndicatorFindSpy.restore()
    done(err)
  )

)
