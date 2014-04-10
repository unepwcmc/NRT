assert = chai.assert

suite('ThemeFilterItemView')

test("when clicked it triggers 'indicator_selector:theme_selected' on Backbone,
  passing in the theme of the view", ->
  view = new Backbone.Views.ThemeFilterItemView(
    theme: Factory.theme()
  )

  eventSpy = sinon.spy()
  Backbone.on('indicator_selector:theme_selected', eventSpy)
  view.$el.trigger('click')

  try
    assert.strictEqual eventSpy.callCount, 1,
      "Expected 'indicator_selector:theme_selected' to be triggered once"

    assert.isTrue eventSpy.calledWith(view.theme),
      "Expected the event 'indicator_selector:theme_selected' to be triggered with the view's theme"
  finally
    Backbone.off('indicator_selector:theme_selected', eventSpy)
    view.close()
)

test("when clicked, it sets the 'active' attribute on the theme to `true`", ->
  view = new Backbone.Views.ThemeFilterItemView(
    theme: Factory.theme()
  )

  view.$el.trigger('click')

  try
    assert.isTrue view.theme.get('active'),
      "Expected the view to have the active attribute"
  finally
    view.close()
)

test("On 'indicator_selector:theme_selected' from another view,
 the view removes the active attribute from the model", ->
  view = new Backbone.Views.ThemeFilterItemView(
    theme: Factory.theme(
      active: true
    )
  )

  Backbone.trigger('indicator_selector:theme_selected')

  try
    assert.isFalse view.theme.get('active'),
      "Expected the view not to have the active attribute"
  finally
    view.close()
)
