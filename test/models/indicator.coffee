assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Indicator = require('../../models/indicator')
fs = require 'fs'

suite('Indicator')

test(".find reads the definition from definitions/indicators.json
and returns an indicator with the correct attributes for that ID", (done)->
  definitions = [
    {id: 1, type: 'esri'},
    {id: 5, type: 'standard'}
  ]
  readFileStub = sinon.stub(fs, 'readFile', (filename, callback) ->
    callback(null, JSON.stringify(definitions))
  )

  Indicator.find(5).then((indicator) ->
    try
      assert.isTrue readFileStub.calledWith('./definitions/indicators.json'),
        "Expected find to read the definitions file"

      assert.property indicator, 'type',
        "Expected the type property from the JSON to be populated on indicator model"

      assert.strictEqual indicator.type, 'standard',
        "Expected the type property to be populated correctly from the definition"

      done()
    catch err
      done(err)
    finally
      readFileStub.restore()
  ).fail(done)
)

test(".query loads and formats the data based on its source", ->
  indicator = new Indicator(
    source: "gdoc"
  )

  gotData = {some: 'data'}
  getDataStub = sinon.stub(indicator, 'getDataFrom', ->
    Q.fcall(-> gotData)
  )

  formatDataFrom = sinon.stub(indicator, 'formatDataFrom', ->
    Q.fcall(-> {})
  )

  assert.isTrue(
    getDataStub.calledWith(indicator.source),
    "Expected getDataFrom to be called with the indicator source"
  )

  assert.isTrue(
    formatDataFrom.calledWith(indicator.source, gotData),
    "Expected formatDataFrom to be called with the indicator source and fetched data"
  )
)
