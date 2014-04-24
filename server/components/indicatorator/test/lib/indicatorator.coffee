assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
fs = require 'fs'
Q = require('q')

GDocGetter = require('../../getters/gdoc')
Indicator = require('../../../../models/indicator').model
Indicatorator = require('../../lib/indicatorator')
RangeApplicator = require('../../lib/range_applicator')
SubIndicatorator = require('../../lib/subindicatorator')

suite('Indicatorator')

test(".getData loads and formats the data based on its source", (done) ->
  indicator = new Indicator(
    indicatoration:
      source: "esri"
  )

  sandbox = sinon.sandbox.create()

  gotData = {some: 'data'}
  fetchDataStub = sandbox.stub(Indicatorator, 'fetchData', ->
    Q.fcall(-> gotData)
  )

  formattedData = {fancy: 'data'}
  formatDataStub = sandbox.stub(Indicatorator, 'formatData', -> formattedData)

  applyRangesStub = sandbox.stub(RangeApplicator, 'applyRanges', (data) ->
    data
  )

  Indicatorator.getData(indicator).then( (data) ->
    try
      assert.isTrue(
        fetchDataStub.calledOnce,
        "Expected getData to be called"
      )

      formatDataCallArgs = formatDataStub.getCall(0).args

      assert.isTrue(
        formatDataStub.calledWith(indicator.indicatoration.source, gotData),
        "Expected formatData to be called with the indicator source and the fetched data,
        but was called with #{JSON.stringify formatDataCallArgs}"
      )

      assert.deepEqual data, formattedData,
        "Expected the formatted data to be returned"

      done()
    catch err
      done(err)
    finally
      sandbox.restore()
  ).fail((err) ->
    sandbox.restore()
    done(err)
  )
)

test(".getData doesn't apply ranges if the indicator has
  indicatoration.applyRanges: false", (done)->
  indicator = new Indicator(
    indicatoration:
      applyRanges: false
  )

  sandbox = sinon.sandbox.create()

  applyRangesStub = sandbox.stub(RangeApplicator, 'applyRanges')
  sandbox.stub(Indicatorator, 'fetchData', ->
    Q.fcall(->)
  )
  sandbox.stub(Indicatorator, 'formatData', ->)

  Indicatorator.getData(indicator).then( (data) ->
    try
      assert.strictEqual applyRangesStub.callCount, 0,
        "Expected RangeApplicator.applyRanges not to be called"
      done()
    catch err
      done(err)
    finally
      sandbox.restore()
  ).catch((err)->
    sandbox.restore()
    done(err)
  )
)

test(".query groups sub indicators if the indicator definition includes
 a reduceField attribute", (done)->
  indicator = new Indicator(
    indicatoration:
      reduceField: 'station'
  )

  sandbox = sinon.sandbox.create()

  groupStub = sandbox.stub(
    SubIndicatorator, 'groupSubIndicatorsUnderAverageIndicators'
  )
  theData = {id: 5}
  sandbox.stub(RangeApplicator, 'applyRanges', -> theData)

  sandbox.stub(Indicatorator, 'fetchData', ->
    Q.fcall(->)
  )
  sandbox.stub(Indicatorator, 'formatData', ->)

  Indicatorator.getData(indicator).then(->
    try
      assert.strictEqual groupStub.callCount, 1,
        "Expected SubIndicatorator.groupSubIndicatorsUnderAverageIndicators to be called once"

      assert.isTrue groupStub.calledWith(
        theData, {valueField: 'value', reduceField: indicator.indicatoration.reduceField}
      ), "Expected groupSubIndicatorsUnderAverageIndicators to be called with the data and the field grouping data"

      done()
    catch err
      done(err)
    finally
      sandbox.restore()
  ).catch((err)->
    sandbox.restore()
    done(err)
  )
)


test('.fetchData finds the getter for the indicator.source and calls fetch on it', (done) ->
  indicator = new Indicator(
    indicatoration:
      source: "gdoc"
  )

  indicatorOfGetter = null
  getterFetchStub = sinon.stub(GDocGetter::, 'fetch', ->
    indicatorOfGetter = @indicator
    Q.fcall(->)
  )

  Indicatorator.fetchData(indicator).then( (data) ->
    try
      assert.isTrue(
        getterFetchStub.calledOnce,
        "Expected getter.fetch to be called once, but called #{getterFetchStub.callCount}"
      )

      assert.deepEqual indicatorOfGetter, indicator,
        "Expected the getter to refer to the supplied indicator"

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

test('.fetchData throws an error if there is no getter for the source', ->
  indicator = new Indicator(
    indicatoration:
      source: "this_source_does_not_exist"
  )

  assert.throw( (->
    Indicatorator.fetchData(indicator)
  ), "No known getter for source 'this_source_does_not_exist'")
)


test('.formatData throws an error if there is no formatter for the source', ->

  assert.throw( (->
    Indicatorator.formatData("this_source_does_not_exist", [])
  ), "No known formatter for source 'this_source_does_not_exist'")
)