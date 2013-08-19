assert = chai.assert

createAndShowVisualisationViewForVisualisation = (visualisation) ->
  view = new Backbone.Views.VisualisationView(visualisation: visualisation)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Visualisation View')

test("Can see barchart view", ->
  visualisation = new Backbone.Models.Visualisation(
    indicator: Helpers.factoryIndicator()
    data: [
      year: '3030', value: '20'
    ]
  )

  view = createAndShowVisualisationViewForVisualisation(visualisation)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name is "BarChartView" and subView.visualisation is visualisation
      subViewExists = true

  assert subViewExists, "could not find bar-chart sub-view for section"

  view.close()
)
