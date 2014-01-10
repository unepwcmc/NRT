assert = chai.assert

suite('IndicatorSelectorView')

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
    searchResults: new Backbone.Collections.IndicatorCollection()
    filterIndicators: Backbone.Views.IndicatorSelectorView::filterIndicators

  filterThemeIndicator  = Factory.indicator()

  collectionFilterByThemeStub = sinon.stub(view.indicators, 'filterByTheme', ->
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
    searchResults: new Backbone.Collections.IndicatorCollection()
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
      collectionFilterByTitleStub.calledTwice,
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

test("Theme filtering and text search work in concert", ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  theme = Factory.theme()
  matchingIndicator = Factory.indicator(
    title: "Matching title and theme"
    theme: theme.get('_id')
  )

  indicators = [
    matchingIndicator
    {title: "Matching title only", theme: Factory.findNextFreeId('Theme')}
    {title: "Matches theme only", theme: Factory.findNextFreeId('Theme')}
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

  try
    assert.lengthOf view.results.models, 1,
      "Expected the results to only contain one element"
    assert.deepEqual view.results.models[0], matchingIndicator,
      "Expected the only result to be the indicator which matches both theme and search"
  finally
    view.close()
    populateCollectionStub.restore()
)
