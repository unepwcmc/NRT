assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Indicator = require('../../models/indicator')
fs = require 'fs'
Q = require('q')
GDocGetter = require('../../getters/gdoc')

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

test(".query loads and formats the data based on its source", (done) ->
  indicator = new Indicator(
    source: "gdoc"
  )

  gotData = {some: 'data'}
  getDataStub = sinon.stub(indicator, 'getData', ->
    Q.fcall(-> gotData)
  )

  formatData = sinon.stub(indicator, 'formatData', ->)

  indicator.query().then( ->
    try
      assert.isTrue(
        getDataStub.calledOnce,
        "Expected getData to be called"
      )

      formatDataCallArgs = formatData.getCall(0).args

      assert.isTrue(
        formatData.calledWith(gotData),
        "Expected formatData to be called with the fetched data,
        but was called with #{formatDataCallArgs}"
      )

      done()
    catch err
      done(err)
  ).fail(done)
)

test('.getData throws an error if there is no getter for the source', ->
  indicator = new Indicator(
    source: "this_source_does_not_exist"
  )

  assert.throw( (->
    indicator.getData()
  ), "No known getter for source 'this_source_does_not_exist'")
)
