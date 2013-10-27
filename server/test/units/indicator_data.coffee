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

test("#roundHeadlineValues truncates decimals to 1 place", ->
  result = IndicatorData.roundHeadlineValues([{value: 0.123456789}])

  assert.strictEqual result[0].value, 0.1
)

test("#roundHeadlineValues when given a value which isn't a number, does nothing", ->
  result = IndicatorData.roundHeadlineValues([{value: 'hat'}])

  assert.strictEqual result[0].value, 'hat'
)

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
