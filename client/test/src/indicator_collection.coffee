assert = chai.assert

suite('IndicatorCollection')

test('.groupByType returns the indicators grouped by primary or secondary', ->
  collection = new Backbone.Collections.IndicatorCollection([{
    type: 'esri'
  }, {
    type: 'esri'
  }, {
    type: 'esri'
  }, {
    type: 'cartodb'
  }, {
    type: 'world bank'
  }])

  groupedIndicators = collection.groupByType()

  assert.lengthOf groupedIndicators.primary, 3
  assert.lengthOf groupedIndicators.secondary, 2
)
