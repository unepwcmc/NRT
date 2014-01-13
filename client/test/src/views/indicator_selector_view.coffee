assert = chai.assert

suite('IndicatorSelectorView')

dummyFetch = ->
  defer = $.Deferred()
  @set([])
  defer.resolve()
  defer.promise()

test('populateCollections populates indicators from the server', (done)->
  server = sinon.fakeServer.create()

  indicators = [title: 'hat']

  indicatorSelector =
    indicators: new Backbone.Collections.IndicatorCollection([], withData: true)

  Backbone.Views.IndicatorSelectorView::populateCollections.call(indicatorSelector).then(->
    try
      Helpers.Assertions.assertPathVisited(server, new RegExp("/api/indicators"))

      assert.strictEqual(
        indicatorSelector.indicators.at(0).get('title'), indicators[0].title
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
  and renders an IndicatorSelectorResultsView', ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicatorTitle = 'An indicator'
  indicators = [{_id: 1, title: indicatorTitle}]

  populateCollectionStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'populateCollections', ->
      defer = $.Deferred()

      @indicators.set(indicators)
      defer.resolve()

      defer.promise()
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  try
    Helpers.assertCalledOnce(populateCollectionStub)

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
    populateCollectionStub.restore()
)

test('Renders a ThemeFilters sub view with the collection of indicators', ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicators = [{_id: 1, title: "Such Theme"}]

  populateCollectionStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'populateCollections', ->
      defer = $.Deferred()

      @indicators.set(indicators)
      defer.resolve()

      defer.promise()
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
    populateCollectionStub.restore()
)

test("When 'indicator_selector:theme_selected' is triggered,
  view.filterByTheme is called", ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  themes = [Factory.theme()]

  filterByThemeStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'filterByTheme', ->
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  theme = themes[0]

  Backbone.trigger('indicator_selector:theme_selected', theme)

  try
    Helpers.assertCalledOnce(filterByThemeStub)
    assert.isTrue filterByThemeStub.calledWith(theme),
      "Expected filterByTheme to be called with the theme of the event"
  finally
    filterByThemeStub.restore()
)

test('When `indicator_selector:indicator_selected` event is fired on backbone
 it triggers the `indicatorSelected` event on itself', (done)->
  indicatorText = 'hats'
  indicatorAttributes = [{
    type: 'cartodb'
    title: indicatorText
  }]

  populateCollectionStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'populateCollections', ->
      defer = $.Deferred()

      @indicators.set(indicatorAttributes)
      defer.resolve()

      defer.promise()
  )

  view = new Backbone.Views.IndicatorSelectorView()

  indicatorSelectedCallback = (indicator) ->
    try
      assert.strictEqual indicator.get('title'), indicatorText
      done()
    catch err
      done(err)
    finally
      populateCollectionStub.restore()

  view.on('indicatorSelected', indicatorSelectedCallback)

  try
    Backbone.trigger(
      'indicator_selector:indicator_selected', view.indicators.at(0)
    )
  finally
    view.close()
    populateCollectionStub.restore()
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

test(".filterByTitle given an input event sets the results object to only
 indicators with a matching title", ->
  view =
    indicators: new Backbone.Collections.IndicatorCollection([])
    results: new Backbone.Collections.IndicatorCollection()
    textFilteredIndicators: new Backbone.Collections.IndicatorCollection()
    filterIndicators: Backbone.Views.IndicatorSelectorView::filterIndicators

  event = target: '<input value="hats and boats and cats">'

  filterTitleIndicator = Factory.indicator()
  collectionFilterByTitleStub = sinon.stub(
    Backbone.Collections.IndicatorCollection::, 'filterByTitle', ->
      return [filterTitleIndicator]
  )

  Backbone.Views.IndicatorSelectorView::filterByTitle.call(
    view, event
  )

  try
    assert.ok(
      collectionFilterByTitleStub.calledOnce,
      "Expected filterByTitle to be called once but was called
        #{collectionFilterByTitleStub.callCount} times"
    )

    assert.lengthOf view.results.models, 1,
      "Expected the collection to be filtered to only the correct indicator"

    assert.deepEqual view.results.at(0), filterTitleIndicator,
      "Expected the result indicator to be the correct one for the given theme"
  finally
    collectionFilterByTitleStub.restore()
)

test('.filterByType sets a type attribute on the @filter', ->
  view =
    filterIndicators: sinon.spy()

  type = 'kittens'
  Backbone.Views.IndicatorSelectorView::filterByType.call(view, type)

  assert.property view, 'filter',
    "Expected the view to have a filter attribute created"
  assert.strictEqual view.filter.type, type,
    "Expected the filter to have the correct type attribute"

  assert.strictEqual view.filterIndicators.callCount, 1,
    "Expected filterIndicators to be called with the new filters"
)

test("When the data origin sub view triggers 'selected', 
 filterByType is triggered", sinon.test(->

  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )


  @stub(Backbone.Collections.IndicatorCollection::, 'fetch', dummyFetch)
  @stub(Backbone.Collections.ThemeCollection::, 'fetch', dummyFetch)

  filterByTypeStub = @stub(
    Backbone.Views.IndicatorSelectorView::, 'filterByType'
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  dataOriginSubView = view.subViews['data-origin-selector']

  dataOriginSubView.trigger('selected', 'kittens')
  assert.strictEqual view.filterByType.callCount, 1,
    "Expected filterByType to called"

  assert.isTrue filterByTypeStub.calledWith('kittens'),
    "Expected filterByType to be called with the argument of the 'selected' event"
))

test(".filterIndicators filters the results by calling
 IndicatorCollection::filterByType with filter.type", sinon.test(->
  view =
    indicators: new Backbone.Collections.IndicatorCollection([])
    results: new Backbone.Collections.IndicatorCollection()
    textFilteredIndicators: new Backbone.Collections.IndicatorCollection()
    filterIndicators: Backbone.Views.IndicatorSelectorView::filterIndicators
    filter: type: 'cygnet'

  filterTypeIndicator = Factory.indicator()
  collectionFilterByTypeStub = @stub(
    Backbone.Collections.IndicatorCollection::, 'filterByType', ->
      return [filterTypeIndicator]
  )

  Backbone.Views.IndicatorSelectorView::filterIndicators.call(view)

  assert.ok(
    collectionFilterByTypeStub.calledOnce,
    "Expected filterByType to be called once but was called
      #{collectionFilterByTypeStub.callCount} times"
  )

  assert.ok(
    collectionFilterByTypeStub.calledWith('cygnet'),
    "Expected collectionFilterByType to be called with the type"
  )

  assert.lengthOf view.results.models, 1,
    "Expected the collection to be filtered to only the correct indicator"

  assert.deepEqual view.results.at(0), filterTypeIndicator,
    "Expected the result indicator to be the correct one for the given theme"
))

test("Theme filtering, type filtering and text search work in concert", ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  theme = Factory.theme()
  matchingIndicator = Factory.indicator(
    title: "Matching title, theme and type"
    theme: theme.get('_id')
    type: 'cygnet'
  )

  indicators = [
    matchingIndicator
    {title: "Matching title and theme only", theme: theme.get('_id')}
    {title: "Matches theme and type only", theme: theme.get('_id'), type: 'cygnet'}
    {title: "Matching title and type only", theme: Factory.findNextFreeId('Theme'), type: 'cygnet'}
  ]

  populateCollectionStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'populateCollections', ->
      defer = $.Deferred()

      @indicators.set(indicators)
      defer.resolve()

      defer.promise()
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  view.filterByTheme(theme)
  view.filterByTitle({target: '<input value="Matching">'})
  view.filterByType('cygnet')

  try
    assert.lengthOf view.results.models, 1,
      "Expected the results to only contain one element"
    assert.deepEqual view.results.models[0], matchingIndicator,
      "Expected the only result to be the indicator which matches both theme and search"
  finally
    view.close()
    populateCollectionStub.restore()
)

test('.clearSearch sets the search term filter to nothing and calls
 .filterIndicators', ->
  view =
    filter:
      searchTerm: "hats"
    filterIndicators: sinon.spy()
    $el: $('<div>')

  Backbone.Views.IndicatorSelectorView::clearSearch.call(view)

  assert.lengthOf view.filter.searchTerm, 0,
    "Expected search term to be blank"

  assert.ok(
    view.filterIndicators.calledOnce,
    "Expected filterIndicators to be called once but was called
      #{view.filterIndicators.callCount} times"
  )
)
