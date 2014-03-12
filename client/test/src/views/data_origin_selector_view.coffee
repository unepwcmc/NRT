suite("DataOriginSelectorView")

test("contains a list of ::Origins", ->
  assert.typeOf Backbone.Views.DataOriginSelectorView::Origins, "Object"
)

test("renders the list of ::Origins", ->
  view = new Backbone.Views.DataOriginSelectorView()

  view.Origins =
    kittens: 'Lovely Kitten Corp.'
    dogs: 'Passable Doge Institute'

  view.render()

  assert.match view.$el.text(), new RegExp('Lovely Kitten Corp.'),
    "Expected the view to contain the human readable name from the origins list"

  assert.lengthOf view.$el.find("option[value='dogs']"), 1,
    "Expected the view to contain an option with the origin name"

  assert.lengthOf view.$el.find(".fancy-select"), 1,
    "Expected the view to contain a FancySelect element for the origin selector"

  assert.lengthOf view.$el.find("li[value='dogs']"), 1,
    "Expected the view to contain a FancySelect list item element with the origin name"
)

test("When an option is selected, the view triggers a 'selected' event with the
origin name", ->
  view = new Backbone.Views.DataOriginSelectorView()

  view.Origins =
    kittens: 'Lovely Kitten Corp.'
    dogs: 'Passable Doge Institute'

  view.render()

  selectedSpy = sinon.spy()
  Backbone.on('indicator_selector:data_origin:selected', selectedSpy)

  view.$el.find("li[value='kittens']").trigger('click')

  try
    assert.isTrue(
      selectedSpy.calledOnce,
      "Expected selectedSpy to be called once but was called
        #{selectedSpy.callCount} times"
    )

    assert.isTrue(
      selectedSpy.calledWith('kittens'),
      "Expected the event to be triggered with the origin name"
    )
  finally
    Backbone.off('indicator_selector:data_origin:selected')
)

test("When 'All sources' is selected, the view triggers a 'selected' event with 
undefined as an argument", ->
  view = new Backbone.Views.DataOriginSelectorView()

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
