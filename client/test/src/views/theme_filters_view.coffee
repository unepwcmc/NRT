assert = chai.assert

suite('ThemeFiltersView')

test('renders a ThemeFilterItem sub view for each theme in the given collection  ', ->
  theme = Factory.theme(title: 'test theme')
  themes = new Backbone.Collections.ThemeCollection([theme])

  view = new Backbone.Views.ThemeFiltersView(themes: themes)

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

test('re-renders when the theme collection syncs', ->
  theme = Factory.theme(title: 'test theme')
  themes = new Backbone.Collections.ThemeCollection([])

  view = new Backbone.Views.ThemeFiltersView(themes: themes)

  assert.isTrue _.isEmpty(view.subViews),
    "Expected the view to have no sub views, as the themes collection is empty"

  themes.reset([theme])
  themes.trigger('sync')

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
