assert = chai.assert

suite('IndicatorCollection')

test(".url with no options returns the indicator api without filtering parameters", ->
  collection = new Backbone.Collections.IndicatorCollection([])

  assert.notMatch collection.url(), new RegExp(".*?withData=true.*"),
    "Expected the URL to include the widthData parameter"
)

test(".url when initialized with withData: true it adds that parameter to the fetch url", ->
  collection = new Backbone.Collections.IndicatorCollection([], withData: true)

  assert.match collection.url(), new RegExp(".*?withData=true.*"),
    "Expected the URL to include the widthData parameter"
)

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
