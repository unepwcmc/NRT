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

test(".updateIndicatorData calls Indicatorator.getData(indicator) and updates
  the indicator data with the result", (done) ->
  Indicatorator = require('../../components/indicatorator/lib/indicatorator.coffee')

  indicator = new Indicator(
    indicatorDefinition:
      fields: []
  )

  sinon.stub(indicator, 'replaceIndicatorData', ->
    Q.fcall(->)
  )

  indicatoratorGetDataStub = sinon.stub(Indicatorator, 'getData', (indicator) ->
    Q.fcall(->
      []
    )
  )


  indicator.updateIndicatorData().then(->
    try
      assert.strictEqual indicatoratorGetDataStub.callCount, 1,
        "Expected Indicatorator.getData to be called"
      assert.isTrue indicatoratorGetDataStub.calledWith(indicator),
        "Expected Indicatorator.getData to be called with the indicator"

      assert.strictEqual indicator.replaceIndicatorData.callCount, 1,
        "Expected the indicator.replaceIndicatorData to be called"
      expectedIndicatorData = {indicator: indicator._id, data: []}
      replacedIndicatorData = indicator.replaceIndicatorData.getCall(0).args[0]
      assert.isTrue indicator.replaceIndicatorData.calledWith(expectedIndicatorData),
        "Expected the indicator data to be replaced with #{JSON.stringify(expectedIndicatorData)},
        but got #{JSON.stringify(replacedIndicatorData)}"

      done()
    catch err
      done(err)
    finally
      indicatoratorGetDataStub.restore()
  ).fail((err)->
    indicatoratorGetDataStub.restore()
    done(err)
  )

)
