assert = require('chai').assert
ThemePresenter = require('../../../lib/presenters/theme')
Theme = require('../../../models/theme').model
Indicator = require('../../../models/theme').model

suite('ThemePresenter')

test("#populateIndicatorRecencyStats given themes populated
  with indicators with headlines
  it populates an 'outOfDateIndicatorCount' attribute
  and an 'isUpToDate' attribute on each indicator", ->
  theme = new Theme()

  upToDateIndicator = new Indicator()
  upToDateIndicator.narrativeRecency = 'Up to date'

  outOfDateIndicator = new Indicator()
  outOfDateIndicator.narrativeRecency = 'Out of date'

  anotherOutOfDateIndicator = new Indicator()
  anotherOutOfDateIndicator.narrativeRecency = 'Out of date'

  theme.indicators = [upToDateIndicator, outOfDateIndicator, anotherOutOfDateIndicator]

  ThemePresenter.populateIndicatorRecencyStats([theme])

  assert.property theme, 'outOfDateIndicatorCount',
    "Expected the outOfDateIndicatorCount to be populated"

  assert.strictEqual theme.outOfDateIndicatorCount, 2,
    "Expected the outOfDateIndicatorCount to be 2"

  assert.property upToDateIndicator, 'isUpToDate',
    "Expected the indicators to have an 'isUpToDate' attribute"

  assert.isTrue upToDateIndicator.isUpToDate,
    "Expected the upToDateIndicator.isUpToDate to be true"

  assert.isFalse outOfDateIndicator.isUpToDate,
    "Expected the outOfDateIndicator.isUpToDate to be fals"
)
