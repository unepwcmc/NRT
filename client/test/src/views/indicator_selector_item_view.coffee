assert = chai.assert

suite('IndicatorSelectorItemView')

test("when clicked it triggers 'indicator_selector:indicator_selected' on Backbone,
  passing in the indicator of the view", ->
  view = new Backbone.Views.IndicatorSelectorItemView(
    indicator: Factory.indicator()
  )

  eventSpy = sinon.spy()
  Backbone.on('indicator_selector:indicator_selected', eventSpy)
  view.$el.trigger('click')

  try
    assert.strictEqual eventSpy.callCount, 1,
      "Expected 'indicator_selector:indicator_selected' to be triggered once"

    assert.isTrue eventSpy.calledWith(view.indicator),
      "Expected the event 'indicator_selector:indicator_selected' to be triggered with the view's indicator"
  finally
    Backbone.off('indicator_selector:indicator_selected', eventSpy)
)

test("renders to the theme title", ->
  theme = Factory.theme(title: "Lovely lovely theme")
  indicator = Factory.indicator(theme: theme.get(Backbone.Models.Theme::idAttribute))

  view = new Backbone.Views.IndicatorSelectorItemView(indicator: indicator)

  assert.match view.$el.text(), new RegExp(theme.get('title')),
    "Expected to see the theme title"
)
