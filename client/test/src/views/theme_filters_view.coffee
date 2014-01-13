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

test("When filtering by a theme, the 'All Indicators' element should be de-activated", ->
  indicators = new Backbone.Collections.IndicatorCollection()

  theme = Factory.theme()

  themeFetchStub = sinon.stub(
    Backbone.Collections.ThemeCollection::, 'fetch', ->
      defer = $.Deferred()

      @set([theme])
      defer.resolve()

      defer.promise()
  )

  view = new Backbone.Views.ThemeFiltersView(indicators: indicators)

  try
    assert.isTrue view.allIndicatorsFilterActive(),
      "Expected allIndicatorsFilterActive to be active when there are no active themes"

    Backbone.trigger('indicator_selector:theme_selected', theme)
    theme.set('active', true)

    assert.isFalse view.allIndicatorsFilterActive(),
      "Expected allIndicatorsFilterActive to be false once a theme filter is activated"

    assert.isFalse view.$el.find('.all-indicators').hasClass('active'),
      "Expected the view have updated the DOM to show 'All Indicators' as false"
  finally
    themeFetchStub.restore()
    view.close()
)
