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

test('.filterBySource given an undefined sourceName returns all indicators', ->
  indicators = new Backbone.Collections.IndicatorCollection([
    {source: name: 'hats'},
    {source: name: 'boats'}
  ])

  results = indicators.filterBySource()

  assert.lengthOf results, 2,
    "Expected the full collection to be returned"
)

test('.filterBySource given an returns only indicators with 
 correct source name', ->
  indicators = new Backbone.Collections.IndicatorCollection([
    {source: name: 'cat'},
    {source: name: 'doge'}
  ])

  results = indicators.filterBySource('doge')

  assert.lengthOf results, 1,
    "Expected the collection to be filtered to only 1 indicator"

  assert.strictEqual results[0].get('source').name, 'doge',
    "Expected the model with the matching source to be returned"
)

test('.getSources returns unique sources', ->
  indicators = new Backbone.Collections.IndicatorCollection([
    {source: name: 'hats'},
    {source: name: 'hats'},
    {source: name: 'cats'}
  ])

  sources = indicators.getSources()

  assert.lengthOf sources, 2,
    "Expected only 2 sources to be returned"

  firstSource = sources[0]
  assert.strictEqual firstSource.name, 'hats',
    "Expected the results to contain the 'hats'"

  secondSource = sources[1]
  assert.strictEqual secondSource.name, 'cats',
    "Expected the results to contain the 'cats'"
)

test('.getSources when an indicator has no source returns nothing', ->
  indicators = new Backbone.Collections.IndicatorCollection({})

  sources = indicators.getSources()

  assert.lengthOf sources, 0,
    "Expected no sources to be returned"
)
