assert = require('chai').assert
sinon = require('sinon')

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

test("#populateIndicators populates the indicators for the given array of themes", ->
  theme1 = new Theme()
  theme1Indicator = new Indicator()
  theme2 = new Theme()
  theme2Indicator = new Indicator()

  getIndicatorsByThemeStub = sinon.stub(Theme, 'getIndicatorsByTheme',  (themeId, callback) ->
    if theme1.id is themeId
      callback(null, theme1Indicator)
    else
      callback(null, theme2Indicator)
  )

  ThemePresenter.populateIndicators([theme1, theme2]).then(->
    try
      assert.property theme1, 'indicators',
        "Expected the theme indicators property to be populated"
      assert.lengthOf theme1.indicators, 1,
        "Expected theme 1 to have one indicator populated"
      assert.strictEqual theme1.indicators[0]._id, theme1Indicator._id,
        "Expected the correct theme indicator to be populated"

      assert.property theme2, 'indicators',
        "Expected the theme indicators property to be populated"
      assert.lengthOf theme2.indicators, 1,
        "Expected theme 2 to have one indicator populated"
      assert.strictEqual theme2.indicators[0]._id, theme2Indicator._id,
        "Expected the correct theme indicator to be populated"

      getIndicatorsByThemeStub.restore()
      done()
    catch err
      getIndicatorsByThemeStub.restore()
      done(err)

  ).fail((err) ->
    getIndicatorsByThemeStub.restore()
    done(err)
  )
)

test("#populateIndicators passes filters to Theme.getIndicatorsByTheme", (done) ->
  filter = {"dpsir.driver": true}
  theme = new Theme()
  getIndicatorsByThemeSpy = sinon.spy(Theme, 'getIndicatorsByTheme')
  ThemePresenter.populateIndicators([theme], filter).then(->
    try
      assert.strictEqual getIndicatorsByThemeSpy.callCount, 1,
        "Expected Theme.getIndicatorsByTheme to be called once"

      assert.deepEqual getIndicatorsByThemeSpy.firstCall.args[1], filter,
        "Expected the filter to be passed to Theme.getIndicatorsByTheme as the second argument"

      done()
    catch err
      done(err)
    finally
      getIndicatorsByThemeSpy.restore()
  ).fail((err) ->
    getIndicatorsByThemeSpy.restore()
    done(err)
  )
)
