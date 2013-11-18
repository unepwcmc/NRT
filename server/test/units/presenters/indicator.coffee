assert = require('chai').assert
IndicatorPresenter = require('../../../lib/presenters/indicator')
Indicator = require('../../../models/indicator').model

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
populates a 'headlineRanges' attribute with the oldest and newest xAxis values", ->
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

  assert.strictEqual indicator.headlineRanges.oldest, 2006,
    "Expected the oldest a headline value to be 2006"

  assert.strictEqual indicator.headlineRanges.newest, 2008,
    "Expected the newest a headline value to be 2008"
)
