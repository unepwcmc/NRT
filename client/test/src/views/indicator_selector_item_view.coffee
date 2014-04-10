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
