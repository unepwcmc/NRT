assert = require('chai').assert
sinon = require('sinon')
Q = require('q')
IndicatorPresenter = require('../../../lib/presenters/indicator')
Indicator = require('../../../models/indicator').model
HeadlineService = require('../../../lib/services/headline')

suite('IndicatorPresentor')

test(".populateSourceFromType on an indicator with a known 'type'
adds a 'source' attribute to the indicator object,
with the correct human readable value", ->
  indicator = Indicator(type: 'esri')

  presenter = new IndicatorPresenter(indicator)
  presenter.populateSourceFromType()

  assert.property indicator, 'source',
    "Expected the indicator to have a 'source' attribute populated"

  assert.strictEqual indicator.source, 'Environment Agency - Abu Dhabi',
    "Expected the indicator to have a 'source' attribute populated"
)

test(".populateHeadlineRangesFromHeadlines when given headlines
populates a 'headlineRanges' attribute with the oldest and newest xAxis values
formatted as D MM YYYY", ->
  indicator = Indicator(
    indicatorDefinition:
      xAxis: 'year'
  )
  headlines = [{
    year: 2006
  }, {
    year: 2007
  }, {
    year: 2008
  }]

  presenter = new IndicatorPresenter(indicator)
  presenter.populateHeadlineRangesFromHeadlines(headlines)

  assert.property indicator, 'headlineRanges',
    "Expected the indicator to have a 'headlineRanges' attribute populated"

  assert.strictEqual indicator.headlineRanges.oldest, '1 Jan 2006',
    "Expected the oldest a headline value to be 2006"

  assert.strictEqual indicator.headlineRanges.newest, '1 Jan 2008',
    "Expected the newest a headline value to be 2008"
)

test(".populateIsUpToDate when narrativeRecency is already present populates 'isUpToDate'
using HeadlineService.narrativeRecencyTextIsUpToDate", (done) ->
  indicator = new Indicator()
  indicator.narrativeRecency = 'Out of date'

  calculateNarrativeRecencySpy = sinon.spy(
    HeadlineService::, 'calculateRecencyOfHeadline'
  )

  isUpToDateStub = sinon.stub(HeadlineService, 'narrativeRecencyTextIsUpToDate', ->
    return true
  )

  new IndicatorPresenter(indicator).populateIsUpToDate().then(->
    try

      assert.strictEqual calculateNarrativeRecencySpy.callCount, 0,
        "Expected HeadlineServices.calculateRecencyOfHeadline not to be called once"
      assert.strictEqual isUpToDateStub.callCount, 1,
        "Expected HeadlineServices.narrativeRecencyTextIsUpToDate to be called once"

      assert.property indicator, 'isUpToDate',
        "Expected the isUpToDate attribute to be populated"
      assert.isTrue indicator.isUpToDate,
        "Expected the isUpToDate attribute to be populated"

      done()
    catch e
      done(e)
    finally
      calculateNarrativeRecencySpy.restore()
      isUpToDateStub.restore()
  ).fail((e)->
    calculateNarrativeRecencySpy.restore()
    isUpToDateStub.restore()
    done(e)
  )
)

test(".populateIsUpToDate when narrativeRecency isn't already present
calls HeadlineService.calculateRecencyOfHeadline then populates 'isUpToDate'
using HeadlineService.narrativeRecencyTextIsUpToDate", (done)->
  indicator = new Indicator()

  calculateNarrativeRecencyStub = sinon.stub(
    HeadlineService::, 'calculateRecencyOfHeadline', ->
      Q.fcall(-> 'Out of date')
  )

  isUpToDateStub = sinon.stub(HeadlineService, 'narrativeRecencyTextIsUpToDate', ->
    return true
  )

  new IndicatorPresenter(indicator).populateIsUpToDate().then(->
    try

      assert.strictEqual calculateNarrativeRecencyStub.callCount, 1,
        "Expected HeadlineServices.calculateNarrativeRecencyStub to be called once"
      assert.strictEqual isUpToDateStub.callCount, 1,
        "Expected HeadlineServices.narrativeRecencyTextIsUpToDate to be called once"

      assert.property indicator, 'isUpToDate',
        "Expected the isUpToDate attribute to be populated"
      assert.isTrue indicator.isUpToDate,
        "Expected the isUpToDate attribute to be populated"

      done()
    catch e
      done(e)
    finally
      calculateNarrativeRecencyStub.restore()
      isUpToDateStub.restore()
  ).fail((e)->
    calculateNarrativeRecencyStub.restore()
    isUpToDateStub.restore()
    done(e)
  )
)

test(".populateNarrativeRecency populates a 'narrativeRecency' attribute with a
call to headlineService::calculateRecencyOfHeadline", (done) ->
  headlineRecency = 'Out of date'
  calculateRecencyStub = sinon.stub(HeadlineService::, 'calculateRecencyOfHeadline', ->
    Q.fcall(-> headlineRecency)
  )

  indicator = {}
  presenter = new IndicatorPresenter(indicator)

  presenter.populateNarrativeRecency().then(->
    try
      assert.strictEqual calculateRecencyStub.callCount, 1,
        "Expected HeadlineService::calculateRecencyOfHeadline to be called once"

      assert.strictEqual indicator.narrativeRecency, headlineRecency,
        "Expected the narrative recency to be set to the headline recency"

      done()
    catch e
      done(e)
    finally
      calculateRecencyStub.restore()
  ).fail((e)->
    calculateRecencyStub.restore()
    done(e)
  )

)
