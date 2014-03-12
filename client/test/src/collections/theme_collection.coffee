assert = chai.assert

suite('ThemeCollection')

test(".populateIndicatorCounts given a collection of indicators
 populates an indicatorCount on each theme", ->
   themes = new Backbone.Collections.ThemeCollection([
     Factory.theme(), Factory.theme()
   ])

   indicators = new Backbone.Collections.IndicatorCollection([{
     theme: themes.at(0).get('_id')
   },{
     theme: themes.at(1).get('_id')
   }])

   themes.populateIndicatorCounts(indicators)

   assert.strictEqual 1, themes.at(0).get('indicatorCount')
   assert.strictEqual 1, themes.at(1).get('indicatorCount')
)
