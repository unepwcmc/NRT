_ = require('underscore')
assert = require('chai').assert
async = require('async')
fs = require('fs')
Q = require('q')
sinon = require('sinon')

IndicatorData = require('../../models/indicator_data').model
Indicator = require('../../models/indicator').model

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
    shortName: 'NO2 Concentration'
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
    shortName: 'The indicator'
  )
  indicatorData = new IndicatorData(
    data: [
      date: 1357002000000,
      value: "-",
      text: "Great"
    ]
  )
  indicator2 = new Indicator(
    shortName: 'second Indicator'
  )
  indicatorData2 = new IndicatorData(
    data: [
      date: 1364778000000,
      value: "10",
      text: "Fair"
    ]
  )

  saveIndicator = (indicator, cb) ->
    indicator.save(cb)

  Q.nfcall(
    async.map, [indicator, indicator2], saveIndicator
  ).then((indicators)->
    indicatorData.indicator = indicator
    indicatorData2.indicator = indicator2

    Q.nfcall(
      async.each, [indicatorData, indicatorData2], saveIndicator
    )
  ).then(->
    IndicatorData.dataToSeedJSON()
  ).then((json)->

    try
      seedData = JSON.parse(json)

      assert.lengthOf seedData, 2,
        "Expected the seed data to have only 1 entry"

      indicator1Data = seedData[0]
      assert.strictEqual indicator1Data.indicator, indicator.shortName,
        "Expected the seed data 'indicator' attribute to be the indicator short name"

      assert.deepEqual indicator1Data.data, indicatorData.data,
        "Expected the seed data 'data' to be the same as the indicator"

      assert.notProperty indicator1Data, '_id',
        "Expected the _id attribute to be removed"

      indicator2Data = seedData[1]
      assert.strictEqual indicator2Data.indicator, indicator2.shortName,
        "Expected the seed data 'indicator' attribute to be the indicator short name"

      assert.deepEqual indicator2Data.data, indicatorData2.data,
        "Expected the seed data 'data' to be the same as the indicator"

      assert.notProperty indicator2Data, '_id',
        "Expected the _id attribute to be removed"

      done()
    catch e
      done(e)

  ).fail(done)
)
