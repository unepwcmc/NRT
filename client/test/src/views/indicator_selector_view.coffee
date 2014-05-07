assert = chai.assert

suite('IndicatorSelectorView')

dummyFetch = ->
  Helpers.promisify(=>
    @set([])
  )

test('populateCollections populates indicators from the server', (done)->
  server = sinon.fakeServer.create()

  indicators = [name: 'hat']

  indicatorSelector =
    indicators: new Backbone.Collections.IndicatorCollection([], withData: true)

  Backbone.Views.IndicatorSelectorView::populateCollections.call(indicatorSelector).then(->
    try
      Helpers.Assertions.assertPathVisited(server, new RegExp("/api/indicators"))

      assert.strictEqual(
        indicatorSelector.indicators.at(0).get('name'), indicators[0].name
      )

      done()
    finally
      server.restore()
  ).fail((err)->
    server.restore()
    done(new Error(err))
  )

  server.respondWith(
    new RegExp('/api/indicators.*'),
    JSON.stringify(indicators)
  )

  server.respond()
)

test('.initialize populates the indicators collection,
  sets the results collection to all indicators
  and renders an IndicatorSelectorResultsView', sinon.test(->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicatorName = 'An indicator'
  indicators = [{_id: 1, name: indicatorName}]

  @stub(Backbone.Collections.IndicatorCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set(indicators)
    )
  )
  @stub(Backbone.Collections.ThemeCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set([])
    )
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  try
    assert.deepEqual view.indicators.models, view.results.models,
      "Expected the results collection to be equal to the indicators"

    for subViewKey, subView of view.subViews
      if subView.constructor.name is "IndicatorSelectorResultsView"
        resultSubView = subView

    assert.isDefined resultSubView,
      "Expected the view to have a IndicatorSelectorResultsView sub view"
    assert.deepEqual resultSubView.indicators, view.results,
      "Expected the resultsSubView to reference the results"

  finally
    view.close()
))

test('Renders a ThemeFilters sub view with the collection of indicators', sinon.test(->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicators = [{_id: 1, name: "Such Indicator"}]

  @stub(Backbone.Collections.IndicatorCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set(indicators)
    )
  )
  @stub(Backbone.Collections.ThemeCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set([])
    )
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  try
    for subViewKey, subView of view.subViews
      if subView.constructor.name is "ThemeFiltersView"
        themeFilterView = subView

    assert.isDefined themeFilterView,
      "Expected the view to have a IndicatorSelectorResultsView sub view"
    assert.deepEqual themeFilterView.indicators.models, view.indicators.models,
      "Expected the themeFilterView to reference the themes"
  finally
    view.close()
))

test("When 'indicator_selector:theme_selected' is triggered,
  view.filterByTheme is called", sinon.test(->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  themes = [Factory.theme()]

  @stub(Backbone.Collections.IndicatorCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set([])
    )
  )
  @stub(Backbone.Collections.ThemeCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set([])
    )
  )

  filterByThemeStub = @stub(
    Backbone.Views.IndicatorSelectorView::, 'filterByTheme', ->
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  theme = themes[0]

  Backbone.trigger('indicator_selector:theme_selected', theme)

  Helpers.assertCalledOnce(filterByThemeStub)
  assert.isTrue filterByThemeStub.calledWith(theme),
    "Expected filterByTheme to be called with the theme of the event"
))

test('When `indicator_selector:indicator_selected` event is fired on backbone
 it triggers the `indicatorSelected` event on itself', (done)->
  indicatorName = 'hats'
  indicatorAttributes = [{
    type: 'cartodb'
    name: indicatorName
  }]

  sandbox = sinon.sandbox.create()

  sandbox.stub(Backbone.Collections.IndicatorCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set(indicatorAttributes)
    )
  )
  sandbox.stub(Backbone.Collections.ThemeCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set([])
    )
  )

  view = new Backbone.Views.IndicatorSelectorView()

  indicatorSelectedCallback = (indicator) ->
    try
      assert.strictEqual indicator.get('name'), indicatorName
      done()
    catch err
      done(err)

  view.on('indicatorSelected', indicatorSelectedCallback)

  try
    Backbone.trigger(
      'indicator_selector:indicator_selected', view.indicators.at(0)
    )
  finally
    view.close()
    sandbox.restore()
)

test(".filterByTheme given a theme sets the results object to only
 objects with the same theme id", ->
  filterTheme = Factory.theme()

  view =
    indicators: new Backbone.Collections.IndicatorCollection([])
    results: new Backbone.Collections.IndicatorCollection()
    textFilteredIndicators: new Backbone.Collections.IndicatorCollection()
    filterIndicators: Backbone.Views.IndicatorSelectorView::filterIndicators

  filterThemeIndicator  = Factory.indicator()

  collectionFilterByThemeStub = sinon.stub(view.results, 'filterByTheme', ->
    return [filterThemeIndicator]
  )

  Backbone.Views.IndicatorSelectorView::filterByTheme.call(
    view, filterTheme
  )

  assert.lengthOf view.results.models, 1,
    "Expected the collection to be filtered to only the correct indicator"

  assert.deepEqual view.results.at(0), filterThemeIndicator,
    "Expected the result indicator to be the correct one for the given theme"

  Helpers.assertCalledOnce(collectionFilterByThemeStub)
  assert.isTrue collectionFilterByThemeStub.calledWith(filterTheme)
)

test(".filterByName given an input event sets the results object to only
 indicators with a matching name", ->
  view =
    indicators: new Backbone.Collections.IndicatorCollection([])
    results: new Backbone.Collections.IndicatorCollection()
    textFilteredIndicators: new Backbone.Collections.IndicatorCollection()
    filterIndicators: Backbone.Views.IndicatorSelectorView::filterIndicators
    updateClearSearchButton: ->

  event = target: '<input value="hats and boats and cats">'

  filterNameIndicator = Factory.indicator()
  collectionfilterByNameStub = sinon.stub(
    Backbone.Collections.IndicatorCollection::, 'filterByName', ->
      return [filterNameIndicator]
  )

  Backbone.Views.IndicatorSelectorView::filterByName.call(
    view, event
  )

  try
    assert.ok(
      collectionfilterByNameStub.calledOnce,
      "Expected filterByName to be called once but was called
        #{collectionfilterByNameStub.callCount} times"
    )

    assert.lengthOf view.results.models, 1,
      "Expected the collection to be filtered to only the correct indicator"

    assert.deepEqual view.results.at(0), filterNameIndicator,
      "Expected the result indicator to be the correct one for the given theme"
  finally
    collectionfilterByNameStub.restore()
)

test('.filterBySource sets a sourceName attribute on the @filter', ->
  view =
    filterIndicators: sinon.spy()

  sourceName = 'kittens'
  Backbone.Views.IndicatorSelectorView::filterBySource.call(view, sourceName)

  assert.property view, 'filter',
    "Expected the view to have a filter attribute created"
  assert.strictEqual view.filter.sourceName, sourceName,
    "Expected the filter to have the correct type attribute"

  assert.strictEqual view.filterIndicators.callCount, 1,
    "Expected filterIndicators to be called with the new filters"
)

test("When the data origin sub view triggers 'selected',
 filterBySource is triggered", sinon.test(->

  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  @stub(Backbone.Collections.IndicatorCollection::, 'fetch', dummyFetch)
  @stub(Backbone.Collections.ThemeCollection::, 'fetch', dummyFetch)

  filterBySourceStub = @stub(
    Backbone.Views.IndicatorSelectorView::, 'filterBySource'
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  Backbone.trigger('indicator_selector:data_origin:selected', 'kittens')
  assert.strictEqual view.filterBySource.callCount, 1,
    "Expected filterBySource to called"

  assert.isTrue filterBySourceStub.calledWith('kittens'),
    "Expected filterBySource to be called with the argument of the 'selected' event"
))

test(".filterIndicators filters the results by calling
 IndicatorCollection::filterBySource with filter.sourceName", sinon.test(->
  view =
    indicators: new Backbone.Collections.IndicatorCollection([])
    results: new Backbone.Collections.IndicatorCollection()
    textFilteredIndicators: new Backbone.Collections.IndicatorCollection()
    filterIndicators: Backbone.Views.IndicatorSelectorView::filterIndicators
    filter: sourceName: 'cygnet'

  filterSourceIndicator = Factory.indicator()
  collectionFilterByTypeStub = @stub(
    Backbone.Collections.IndicatorCollection::, 'filterBySource', ->
      return [filterSourceIndicator]
  )

  Backbone.Views.IndicatorSelectorView::filterIndicators.call(view)

  assert.ok(
    collectionFilterByTypeStub.calledOnce,
    "Expected filterBySource to be called once but was called
      #{collectionFilterByTypeStub.callCount} times"
  )

  assert.ok(
    collectionFilterByTypeStub.calledWith('cygnet'),
    "Expected collectionFilterByType to be called with the type"
  )

  assert.lengthOf view.results.models, 1,
    "Expected the collection to be filtered to only the correct indicator"

  assert.deepEqual view.results.at(0), filterSourceIndicator,
    "Expected the result indicator to be the correct one for the given theme"
))

test("Theme filtering, source filtering and text search work in concert",
sinon.test(->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  theme = Factory.theme()
  matchingIndicator = Factory.indicator(
    name: "Matching name, theme and type"
    theme: theme.get('_id')
    source: name: 'cygnet'
  )

  indicators = [
    matchingIndicator
    {
      name: "Matching name and theme only", theme: theme.get('_id')}
    {
      name: "Matches theme and source only",
      theme: theme.get('_id'),
      source: name: 'cygnet'
    },
    {
      name: "Matching name and source only",
      theme: Factory.findNextFreeId('Theme'),
      source: name: 'cygnet'
    }
  ]

  @stub(Backbone.Collections.IndicatorCollection::, 'fetch', ->
    Helpers.promisify(=>
      @set(indicators)
    )
  )
  @stub(Backbone.Collections.ThemeCollection::, 'fetch', dummyFetch)

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  view.filterByTheme(theme)
  view.filterByName({target: '<input value="Matching">'})
  view.filterBySource('cygnet')

  try
    assert.lengthOf view.results.models, 1,
      "Expected the results to only contain one element"
    assert.deepEqual view.results.models[0], matchingIndicator,
      "Expected the only result to be the indicator which matches both theme and search"
  finally
    view.close()
))

test('.clearSearch sets the search term filter to nothing and calls
 .filterIndicators', ->
  view =
    filter:
      searchTerm: "hats"
    filterIndicators: sinon.spy()
    $el: $('<div>')
    updateClearSearchButton: ->

  Backbone.Views.IndicatorSelectorView::clearSearch.call(view)

  assert.lengthOf view.filter.searchTerm, 0,
    "Expected search term to be blank"

  assert.ok(
    view.filterIndicators.calledOnce,
    "Expected filterIndicators to be called once but was called
      #{view.filterIndicators.callCount} times"
  )
)
