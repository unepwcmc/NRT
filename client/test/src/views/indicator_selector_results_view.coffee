assert = chai.assert

suite('IndicatorSelectorResultsView')

test('renders an IndicatorSelectorItem sub view for each result in the given collection  ', ->
  indicator = Factory.indicator(title: 'test indicator')
  indicators = new Backbone.Collections.IndicatorCollection([indicator])

  view = new Backbone.Views.IndicatorSelectorResultsView(indicators: indicators)

  assert.match view.$el.text(), new RegExp(indicator.get('title')),
    "Expected to see the indicator title"

  for key, v of view.subViews
    subView = v

  assert.isDefined subView, "Expected the view to have a subView"
  assert.strictEqual subView.constructor.name, "IndicatorSelectorItemView",
    "Expected the sub view to be of type 'IndicatorSelectorItemView'"

  assert.strictEqual subView.indicator.cid, indicator.cid,
    "Expected the sub view to be for the result indicator"
)

test('re-renders when the indicator collection resets', ->
  indicator = Factory.indicator(title: 'test indicator')
  indicators = new Backbone.Collections.IndicatorCollection([])

  view = new Backbone.Views.IndicatorSelectorResultsView(indicators: indicators)

  assert.isTrue _.isEmpty(view.subViews),
    "Expected the view to have no sub views, as the indicators collection is empty"

  indicators.reset([indicator])

  assert.match view.$el.text(), new RegExp(indicator.get('title')),
    "Expected to see the indicator title"

  for key, v of view.subViews
    subView = v

  assert.isDefined subView, "Expected the view to have a subView"
  assert.strictEqual subView.constructor.name, "IndicatorSelectorItemView",
    "Expected the sub view to be of type 'IndicatorSelectorItemView'"

  assert.strictEqual subView.indicator.cid, indicator.cid,
    "Expected the sub view to be for the result indicator"
)
