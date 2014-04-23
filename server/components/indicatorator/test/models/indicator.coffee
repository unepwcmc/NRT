assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Indicator = require('../../models/indicator')
fs = require 'fs'
Q = require('q')

GDocGetter = require('../../getters/gdoc')
StandardIndicatorator = require('../../indicatorators/standard_indicatorator')
SubIndicatorator = require('../../lib/subindicatorator')

suite('Indicator')

test(".find returns from all indicators the indicator with the correct
  attributes for that ID", (done)->

  definitions = [
    {id: 1, type: 'esri'},
    {id: 5, type: 'standard'}
  ]
  indicatorAllStub = sinon.stub(Indicator, 'all', ->
    Q.fcall(-> definitions)
  )

  Indicator.find("5").then((indicator) ->
    try
      assert.isTrue indicatorAllStub.calledOnce,
        "Expected find to call Indicator.all"

      assert.property indicator, 'type',
        "Expected the type property from the JSON to be populated on indicator model"

      assert.strictEqual indicator.type, 'standard',
        "Expected the type property to be populated correctly from the definition"

      done()
    catch err
      done(err)
    finally
      indicatorAllStub.restore()
  ).fail((err) ->
    indicatorAllStub.restore()
    done(err)
  )
)


test(".find throws an appropriate error when no definition is found", (done)->

  indicatorAllStub = sinon.stub(Indicator, 'all', ->
    Q.fcall(-> [])
  )

  Indicator.find("5").then((indicator) ->
    indicatorAllStub.restore()
    done(new Error("Expected Indicator.find to fail, as there is no definition"))
  ).fail((err) ->
    try
      assert.strictEqual err.message, "No indicator definition found for id '5'",
        "Expected an appropriate error message"

      done()
    catch err
      done(err)
    finally
      indicatorAllStub.restore()
  )
)

test("#all returns all indicators from definition file", (done) ->
  definitions = [
    {id: 1, type: 'esri'},
    {id: 5, type: 'standard'}
  ]
  readFileStub = sinon.stub(fs, 'readFile', (filename, callback) ->
    callback(null, JSON.stringify(definitions))
  )

  Indicator.all().then((result) ->
    try
      assert.isTrue(
        readFileStub.calledWithMatch(
          new RegExp("/definitions/indicators.json")
        ),
        "Expected find to read the definitions file"
      )

      assert.deepEqual(result, definitions,
        "Expected the definitions to be returned"
      )

      done()
    catch err
      done(err)
    finally
      readFileStub.restore()
  ).fail((err) ->
    readFileStub.restore()
    done(err)
  )
)

test("#all throws an appropriate error if definitions can't be parsed", (done) ->
  brokenDefinitions = "[}"
  readFileStub = sinon.stub(fs, 'readFile', (filename, callback) ->
    callback(null, brokenDefinitions)
  )

  Indicator.all().then((result) ->
    readFileStub.restore()
    done(new Error("Indicator.all was expected to fail, but it didn't"))
  ).fail((err) ->
    try
      assert.strictEqual err.message, "Unable to parse ./definitions/indicators.json",
        "Expected the correct error message"

      done()
    catch err
      done(err)
    finally
      readFileStub.restore()
  )
)

test("#all throws an appropriate error if the definitions can't be read", (done) ->
  readFileStub = sinon.stub(fs, 'readFile', (filename, callback) ->
    try
      # Recreate an accurate file missing error
      fs.readFileSync("./does_not_exist", "utf8")
    catch err
      callback(err)
  )

  Indicator.all().then((result) ->
    readFileStub.restore()
    done(new Error("Indicator.all was expected to fail, but it didn't"))
  ).fail((err) ->
    try
      assert.strictEqual err.message, "ENOENT, no such file or directory './does_not_exist'",
        "Expected the correct error message"

      done()
    catch err
      done(err)
    finally
      readFileStub.restore()
  )
)

test('.getData finds the getter for the indicator.source and calls fetch', ->
  indicator = new Indicator(
    source: "gdoc"
  )

  getterFetchStub = sinon.stub(GDocGetter::, 'fetch', ->
    Q.fcall(->)
  )

  indicator.getData().then(->
    try
      assert.isTrue(
        getterFetchStub.calledOnce(),
        "Expected getter.fetch to be called once, but called #{getterFetchStub.callCount}"
      )

      done()
    catch err
      done(err)
    finally
      getterFetchStub.restore()
  ).fail((err) ->
    getterFetchStub.restore()
    done(err)
  )
)

test('.getData throws an error if there is no getter for the source', ->
  indicator = new Indicator(
    source: "this_source_does_not_exist"
  )

  assert.throw( (->
    indicator.getData()
  ), "No known getter for source 'this_source_does_not_exist'")
)

test('.fomatData throws an error if there is no fomatter for the source', ->
  indicator = new Indicator(
    source: "this_source_does_not_exist"
  )

  assert.throw( (->
    indicator.formatData()
  ), "No known formatter for source 'this_source_does_not_exist'")
)
