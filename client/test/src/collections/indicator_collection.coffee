assert = chai.assert

suite('IndicatorCollection')

test('.groupByType returns the indicators grouped by core or external', ->
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

  assert.lengthOf groupedIndicators.core, 3
  assert.lengthOf groupedIndicators.external, 2
)
