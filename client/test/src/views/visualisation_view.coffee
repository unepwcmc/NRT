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

  Helpers.viewHasSubViewOfClass view, "BarChartView"

  view.close()
)

test("When given a visualisation with type Map,
  it renders a MapView subView", ->
  view = createAndShowVisualisationViewForVisualisation(
    Factory.visualisation(
      type: "Map"
    )
  )

  Helpers.viewHasSubViewOfClass view, "MapView"

  view.close()
)
