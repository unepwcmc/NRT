assert = chai.assert

createAndShowVisualisationViewForVisualisation = (visualisation) ->
  view = new Backbone.Views.VisualisationView(visualisation: visualisation)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Visualisation View')

test("When given a visualisation with type BarChart,
  it renders a BarChartView subView", ->
  view = createAndShowVisualisationViewForVisualisation(
    Factory.visualisation(
      type: "BarChart"
    )
  )

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "BarChartView"
      subViewExists = true

  assert.ok subViewExists

  view.close()
)

test("When given a visualisation with type Map,
  it renders a MapView subView", ->
  view = createAndShowVisualisationViewForVisualisation(
    Factory.visualisation(
      type: "Map"
    )
  )

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "MapView"
      subViewExists = true

  assert.ok subViewExists

  view.close()
)