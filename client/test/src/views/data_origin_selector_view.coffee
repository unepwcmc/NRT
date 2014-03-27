suite("DataOriginSelectorView")

test("takes a collection of indicators", ->
  indicators = new Backbone.Collections.IndicatorCollection()

  view = new Backbone.Views.DataOriginSelectorView(indicators: indicators)

  assert.property(view, 'indicators')
  assert.strictEqual(
    view.indicators.cid, indicators.cid,
    "Expected the view to have the indicator as an attribute"
  )
)

test("renders an option for each unique source in the indicator collection", ->
  origins =
    kittens:
      name: 'Lovely Kitten Corp.'
      url: 'http://kittens.org'
    dogs:
      name: 'Passable Doge Institute'
      url: 'http://dogecorpe.com'

  indicators = new Backbone.Collections.IndicatorCollection([{
    source: origins.kittens
  }, {
    source: origins.kittens
  }, {
    source: origins.dogs
  }])

  view = new Backbone.Views.DataOriginSelectorView(indicators: indicators)

  view.render()

  assert.match view.$el.text(), new RegExp('Lovely Kitten Corp.'),
    "Expected the view to contain the human readable name from the origins list"

  assert.lengthOf view.$el.find("option[value='#{origins.kittens.name}']"), 1,
    "Expected the view to contain one option with the kittens origin name"

  assert.lengthOf view.$el.find(".fancy-select"), 1,
    "Expected the view to contain a FancySelect element for the origin selector"

  assert.lengthOf view.$el.find("li[value='#{origins.dogs.name}']"), 1,
    "Expected the view to contain a FancySelect list item element with the origin name"
)

test("When an option is selected, the view triggers a 'selected' event with the
origin name", ->
  origins =
    kittens:
      name: 'Lovely Kitten Corp.'
      url: 'http://kittens.org'
    dogs:
      name: 'Passable Doge Institute'
      url: 'http://dogecorpe.com'

  indicators = new Backbone.Collections.IndicatorCollection([{
    source: origins.kittens
  }, {
    source: origins.kittens
  }, {
    source: origins.dogs
  }])

  view = new Backbone.Views.DataOriginSelectorView(indicators: indicators)

  view.render()

  selectedSpy = sinon.spy()
  Backbone.on('indicator_selector:data_origin:selected', selectedSpy)

  view.$el.find("li[value='#{origins.kittens.name}']").trigger('click')

  try
    assert.isTrue(
      selectedSpy.calledOnce,
      "Expected selectedSpy to be called once but was called
        #{selectedSpy.callCount} times"
    )

    assert.isTrue(
      selectedSpy.calledWith(origins.kittens.name),
      "Expected the event to be triggered with the origin name"
    )
  finally
    Backbone.off('indicator_selector:data_origin:selected')
)

test("When 'All sources' is selected, the view triggers a 'selected' event with 
undefined as an argument", ->
  indicators = new Backbone.Collections.IndicatorCollection()

  view = new Backbone.Views.DataOriginSelectorView(indicators: indicators)

  view.Origins =
    kittens: 'Lovely Kitten Corp.'

  view.render()

  selectedSpy = sinon.spy()
  Backbone.on('indicator_selector:data_origin:selected', selectedSpy)

  $(view.$el.find("option")[0]).prop("selected", true)
  view.$el.find("select").trigger('change')

  try
    assert.isTrue(
      selectedSpy.calledOnce,
      "Expected selectedSpy to be called once but was called
        #{selectedSpy.callCount} times"
    )

    assert.isTrue(
      selectedSpy.calledWith(undefined),
      "Expected the event to be triggered with no origin name"
    )
  finally
    Backbone.off('indicator_selector:data_origin:selected')
)

test("re-renders when the indicator collection resets", ->
  indicators = new Backbone.Collections.IndicatorCollection()

  renderSpy = sinon.spy(Backbone.Views.DataOriginSelectorView::, 'render')
  view = new Backbone.Views.DataOriginSelectorView(indicators: indicators)

  indicators.trigger('reset')

  try
    assert.strictEqual(renderSpy.callCount, 2,
      "Expected DataOriginSelectorView.render to occur second time on 'reset'"
    )
  finally
    renderSpy.restore()
)
