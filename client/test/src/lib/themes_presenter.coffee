suite('ThemePresenter')

test('#populateIndicatorCount given a collection of indicators sets the
 indicator count for that theme on the theme model', ->
   themes = [Factory.theme(),Factory.theme()]

   indicatorsAttributes = [{
     theme: themes[0].get('_id')
   },{
     theme: Factory.findNextFreeId('Theme')
   }]
   indicators = new Backbone.Collections.IndicatorCollection(indicatorsAttributes)

   themePresenter = new Nrt.Presenters.ThemePresenter(themes[0])
   themePresenter.populateIndicatorCount(indicators)

   themePresenter = new Nrt.Presenters.ThemePresenter(themes[1])
   themePresenter.populateIndicatorCount(indicators)

   assert.strictEqual 1, themes[0].get('indicatorCount')
   assert.strictEqual '-', themes[1].get('indicatorCount')
)

test('#populateIndicatorCount not given a collection of indicators does
 nothing', ->
   theme = Factory.theme()

   themePresenter = new Nrt.Presenters.ThemePresenter(theme)
   themePresenter.populateIndicatorCount()

   assert.isUndefined theme.get('indicatorCount')
)
