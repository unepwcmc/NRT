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
)

test("When an option is selected, the view triggers a 'selected' event with the
origin name", (done)->
  view = new Backbone.Views.DataOriginSelectorView()

  view.Origins =
    kittens: 'Lovely Kitten Corp.'
    dogs: 'Passable Doge Institute'

  view.render()

  view.on('selected', (originName) ->
    try
      assert.strictEqual originName, 'kittens',
        "Expected the event to be triggered with the origin name"

      done()
    catch err
      done(err)
  )

  view.$el.find("option[value='kittens']").prop("selected",true)
  view.$el.find("select").trigger('change')
)

test("When 'All sources' is selected, the view triggers a 'selected' event with 
undefined as an argument", (done)->
  view = new Backbone.Views.DataOriginSelectorView()

  view.Origins =
    kittens: 'Lovely Kitten Corp.'

  view.render()

  view.on('selected', (originName) ->
    try
      assert.isUndefined originName,
        "Expected the event to be triggered with no origin name"

      done()
    catch err
      done(err)
  )

  $(view.$el.find("option")[0]).prop("selected", true)
  view.$el.find("select").trigger('change')
)

