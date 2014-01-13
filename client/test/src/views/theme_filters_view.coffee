assert = chai.assert

suite('ThemeFiltersView')

test('renders a ThemeFilterItem sub view for each theme in the given collection', ->
  indicators = new Backbone.Collections.IndicatorCollection()

  view = new Backbone.Views.ThemeFiltersView(indicators: indicators)

  theme = Factory.theme(title: 'test theme')
  themes = new Backbone.Collections.ThemeCollection([theme])

  view.themes = themes
  view.render()

  assert.match view.$el.text(), new RegExp(theme.get('title')),
    "Expected to see the theme title"

  for key, v of view.subViews
    subView = v

  assert.isDefined subView, "Expected the view to have a subView"
  assert.strictEqual subView.constructor.name, "ThemeFilterItemView",
    "Expected the sub view to be of type 'ThemeFilterItemView'"

  assert.strictEqual subView.theme.cid, theme.cid,
    "Expected the sub view to be for the theme"
)

test('.allIndicatorsFilterActive returns true if none of the Themes have
 a true `active` attribute', ->
  indicators = new Backbone.Collections.IndicatorCollection()

  themesAttributes = [{
    active: false,
  },{
    active: false
  }]

  themeFetchStub = sinon.stub(
    Backbone.Collections.ThemeCollection::, 'fetch', ->
      defer = $.Deferred()

      @set(themesAttributes)
      defer.resolve()

      defer.promise()
  )

  view = new Backbone.Views.ThemeFiltersView(indicators: indicators)

  try
    assert.isTrue view.allIndicatorsFilterActive(),
      "Expected allIndicatorsFilterActive to return true"
  finally
    themeFetchStub.restore()
    view.close()
)

test('.allIndicatorsFilterActive returns false if any of the Themes have
 a true `active` attribute', ->
  indicators = new Backbone.Collections.IndicatorCollection()

  themesAttributes = [{
    active: true,
  },{
    active: false
  }]

  themeFetchStub = sinon.stub(
    Backbone.Collections.ThemeCollection::, 'fetch', ->
      defer = $.Deferred()

      @set(themesAttributes)
      defer.resolve()

      defer.promise()
  )

  view = new Backbone.Views.ThemeFiltersView(indicators: indicators)

  try
    assert.isFalse view.allIndicatorsFilterActive(),
      "Expected allIndicatorsFilterActive to return false"
  finally
    themeFetchStub.restore()
    view.close()
)
