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

test(".filterByTheme given a theme returns an array with only
 models with the same theme id", ->
  filterTheme = Factory.theme()

  selectedThemeIndicator = Factory.indicator(
    theme: filterTheme.get('_id')
  )
  differentThemeIndicator = Factory.indicator()

  indicators = new Backbone.Collections.IndicatorCollection([
    selectedThemeIndicator, differentThemeIndicator
  ])

  results = indicators.filterByTheme(filterTheme)

  assert.lengthOf results, 1,
    "Expected the collection to be filtered to only the correct indicator"

  assert.deepEqual results[0], selectedThemeIndicator,
    "Expected the result indicator to be the correct one for the given theme"
)

test(".filterByTitle returns matching indicators, regardless of case", ->
  indicators = new Backbone.Collections.IndicatorCollection([
    {title: 'hats'},
    {title: 'boats'}
  ])

  results = indicators.filterByTitle('oAt')
  assert.lengthOf results, 1
  assert.strictEqual results[0].get('title'), 'boats'
)

test(".filterByTitle returns all indicators if a blank search term is provided", ->
  indicators = new Backbone.Collections.IndicatorCollection([
    {title: 'hats'},
    {title: 'boats'}
  ])

  results = indicators.filterByTitle('')
  assert.lengthOf results, 2
  assert.strictEqual results[0].get('title'), 'hats'
  assert.strictEqual results[1].get('title'), 'boats'
)

test(".filterByTitle ignores extraneous whitespace", ->
  indicators = new Backbone.Collections.IndicatorCollection([
    {title: 'hats'},
    {title: 'boats'}
  ])

  results = indicators.filterByTitle('ha  ')
  assert.lengthOf results, 1
  assert.strictEqual results[0].get('title'), 'hats'
)
