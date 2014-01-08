assert = chai.assert

suite('IndicatorSelectorView')

test('populateCollections populates themes and indicators from the server', (done)->
  server = sinon.fakeServer.create()

  indicators = [title: 'hat']
  themes = [title: 'boat']

  indicatorSelector =
    indicators: new Backbone.Collections.IndicatorCollection([], withData: true)
    themes: new Backbone.Collections.ThemeCollection()

  Backbone.Views.IndicatorSelectorView::populateCollections.call(indicatorSelector).then(->
    try
      Helpers.Assertions.assertPathVisited(server, new RegExp("/api/indicators"))
      Helpers.Assertions.assertPathVisited(server, new RegExp("/api/themes"))

      assert.strictEqual(
        indicatorSelector.indicators.at(0).get('title'), indicators[0].title
      )
      assert.strictEqual(
        indicatorSelector.themes.at(0).get('title'), themes[0].title
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
  server.respondWith(
    new RegExp('/api/themes.*'),
    JSON.stringify(themes)
  )

  server.respond()
)

test('.initialize populates the indicators collection,
  sets the results collection to all indicators
  and renders the results ', ->
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
      "Expected the results collection to be able to the indicators"

    assert.match(
      view.$el.text(),
      new RegExp(".*#{indicatorTitle}.*")
    )

  finally
    view.close()
    populateCollectionStub.restore()
)

test('Renders a list of themes sub views', ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  themes = [{_id: 1, title: "Such Theme"}]

  populateCollectionStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'populateCollections', ->
      defer = $.Deferred()

      @themes.set(themes)
      defer.resolve()

      defer.promise()
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  try
    Helpers.assertCalledOnce(populateCollectionStub)

    assert.match(
      view.$el.text(),
      new RegExp(".*#{themes[0].title}.*")
    )

    assert.isTrue Helpers.viewHasSubViewOfClass(view, 'ThemeFilterItemView'),
      "Expected the view to have a 'ThemeFilterItemView' sub view"
  finally
    view.close()
    populateCollectionStub.restore()
)

test("When a ThemeFilterItemView sub view triggers 'selected',
  view.filterByTheme is called", ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  themes = [{_id: 1, title: "Such Theme"}]

  populateCollectionStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'populateCollections', ->
      defer = $.Deferred()

      @themes.set(themes)
      defer.resolve()

      defer.promise()
  )

  filterByThemeStub = sinon.stub(
    Backbone.Views.IndicatorSelectorView::, 'filterByTheme', ->
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  theme = view.themes.at(0)
  subView = view.subViews["theme-filter-#{theme.cid}"]
  subView.trigger('selected', theme)

  try
    Helpers.assertCalledOnce(filterByThemeStub)
    assert.isTrue filterByThemeStub.calledWith(theme),
      "Expected filterByTheme to be called with the theme of the event"
  finally
    filterByThemeStub.restore()
    populateCollectionStub.restore()
)

test('When an indicator is selected, an `indicatorSelected` event is
  fired with the selected indicator', (done)->
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

  subViews = []
  for key, subView of view.subViews
    subViews.push subView

  try
    assert.lengthOf subViews, 1,
      "Expected the view to have an indicator sub view"
    indicatorItemSubView = subViews[0]
    indicatorItemSubView.trigger('indicatorSelected', indicatorItemSubView.indicator)
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
