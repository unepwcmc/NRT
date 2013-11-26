assert = require('chai').assert
helpers = require '../helpers'
IndicatorData = require('../../models/indicator_data').model
Indicator = require('../../models/indicator').model
async = require('async')
_ = require('underscore')
Q = require 'q'
fs = require 'fs'
sinon = require 'sinon'

suite('Indicator Data')

test('#seedData given some indicators, links the seed data correctly', (done) ->
  indicatorData = [{
    'indicator': 'NO2 Concentration'
    'data': {'some': 'data'}
  }]
  readFileStub = sinon.stub(fs, 'readFileSync', ->
    JSON.stringify(indicatorData)
  )

  indicatorToLinkTo = new Indicator(
    short_name: 'NO2 Concentration'
  )

  IndicatorData.seedData([indicatorToLinkTo]).then((createdIndicatorData) ->
    try

      assert.strictEqual createdIndicatorData.indicator, indicatorToLinkTo._id,
        "Expected the created indicator data to reference the correct indicator"

      done()
    catch err
      done(err)
    finally
      readFileStub.restore()

  ).fail((err) ->
    done(err)
    readFileStub.restore()
  )
  
)

test("#seedData if the seed includes a 'date' field, convert it to an actual date", (done) ->
  epoch = 1357072587
  indicatorData = [{
    'indicator': 'NO2 Concentration'
    'data': [{'date': epoch}]
  }]
  readFileStub = sinon.stub(fs, 'readFileSync', ->
    JSON.stringify(indicatorData)
  )

  IndicatorData.seedData([]).then((createdIndicatorData) ->
    try

      firstDataRow = createdIndicatorData.data[0]
      assert.strictEqual firstDataRow.date.toString(), (new Date(epoch)).toString(),
        "Expected the created data date to be a date object"

      done()
    catch err
      done(err)
    finally
      readFileStub.restore()

  ).fail((err) ->
    done(err)
    readFileStub.restore()
  )
  
)

test("#dataToSeedJSON returns indicator data as JSON with the indicator field
denormalised to the indicator name", (done) ->
  indicator = new Indicator(
    short_name: 'The indicator'
  )
  indicatorData = new IndicatorData(
    data: [
      date: 1357002000000,
      value: "-",
      text: "Great",
    ]
  )

  expectedData = [{
    indicator: indicator.short_name
    data: indicatorData.data
  }]

  Q.nsend(
    indicator, 'save'
  ).then(->
    indicatorData.indicator = indicator

    Q.nsend(
      indicatorData, 'save'
    )
  ).then(->
    IndicatorData.dataToSeedJSON()
  ).then((json)->

    try
      seedData = JSON.parse(json)

      assert.lengthOf seedData, 1,
        "Expected the seed data to have only 1 entry"

      seedDataRow = seedData[0]
      assert.strictEqual seedDataRow.indicator, indicator.short_name,
        "Expected the seed data 'indicator' attribute to be the indicator short name"

      assert.deepEqual seedDataRow.data, indicatorData.data,
        "Expected the seed data 'data' to be the same as the indicator"

      done()
    catch e
      done(e)
    
  ).fail(done)
)
