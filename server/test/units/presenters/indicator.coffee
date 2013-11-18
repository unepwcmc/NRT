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
