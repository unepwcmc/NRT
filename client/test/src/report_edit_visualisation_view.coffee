assert = chai.assert

createAndShowVisualisationViewForOptions = (options) ->
  view = new Backbone.Views.ReportEditVisualisationView(options)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('ReportEditVisualisationView')

test("Shows the given indicator title", ->
  indicatorTitle = "my lovely indicator"
  indicator = new Backbone.Models.Indicator(
    title: indicatorTitle
  )

  view = createAndShowVisualisationViewForOptions(
    indicator: indicator
    visualisation: new Backbone.Models.Visualisation()
  )

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{indicatorTitle}.*")
  )
  view.close()
)

test("Renders a BarChartView", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: new Backbone.Models.Visualisation()
    indicator: new Backbone.Models.Indicator()
  )

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "BarChartView"
      subViewExists = true

  assert.ok subViewExists

  view.close()
)
