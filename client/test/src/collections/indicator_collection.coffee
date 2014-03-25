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

test('.filterByType given an undefined type returns all indicators', ->
  indicators = new Backbone.Collections.IndicatorCollection([
    {type: 'hats'},
    {type: 'boats'}
  ])

  results = indicators.filterByType()

  assert.lengthOf results, 2,
    "Expected the collection to be filtered to only the correct indicator"
)
