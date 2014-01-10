suite('ThemePresenter')

test('#populateIndicatorCount given a collection of indicators sets the
 indicator count for that theme on the theme model', ->
   theme = Factory.theme()

   indicatorsAttributes = [{
     theme: theme.get('_id')
   },{
     theme: Factory.findNextFreeId('Theme')
   }]
   indicators = new Backbone.Collections.IndicatorCollection(indicatorsAttributes)

   themePresenter = new Nrt.Presenters.ThemePresenter(theme)
   themePresenter.populateIndicatorCount(indicators)

   assert.strictEqual 1, theme.get('indicatorCount')
)
