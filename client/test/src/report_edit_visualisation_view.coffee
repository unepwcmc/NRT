assert = chai.assert

createAndShowVisualisationViewForOptions = (options) ->
  view = new Backbone.Views.ReportEditVisualisationView(options)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('ReportEditVisualisationView')

test("Shows the given indicator title", ->
  indicatorTitle = "my lovely indicator"
  indicator = Helpers.factoryIndicator()
  indicator.set('title', indicatorTitle)

  section = new Backbone.Models.Section(
    indicator: indicator
  )

  view = createAndShowVisualisationViewForOptions(
    visualisation: new Backbone.Models.Visualisation(
      indicator: indicator
      section: section
      data: []
    )
  )

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{indicatorTitle}.*")
  )
  view.close()
)

test("Fires a 'close' event when view closed", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: new Backbone.Models.Visualisation(
      indicator: new Backbone.Models.Indicator()
    )
  )

  callback = sinon.spy()
  view.on('close', callback)

  view.closeModal()
  assert(callback.called, "Close event not fired")
)

test("When given a visualisation with type BarChart,
  it renders a BarChartView subView", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: new Backbone.Models.Visualisation(
      type: "BarChart"
      indicator: new Backbone.Models.Indicator()
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
  view = createAndShowVisualisationViewForOptions(
    visualisation: new Backbone.Models.Visualisation(
      type: "Map"
      indicator: new Backbone.Models.Indicator()
    )
  )

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "MapView"
      subViewExists = true

  assert.ok subViewExists

  view.close()
)

test("When given a visualisation with type Table,
  it renders a TableView subView", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: new Backbone.Models.Visualisation(
      type: "Table"
      indicator: new Backbone.Models.Indicator()
    )
  )

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "TableView"
      subViewExists = true

  assert.ok subViewExists

  view.close()
)

test("I see the visualisation type selected", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: new Backbone.Models.Visualisation(
      type: "Map"
      indicator: new Backbone.Models.Indicator()
    )
  )

  assert.strictEqual view.$el.find('option:selected').val(), "Map"
  view.close()
)

test(".updateVisualisationType should set the visualisation type", ->
  visualisation = new Backbone.Models.Visualisation(
    type: "Map"
    indicator: new Backbone.Models.Indicator()
  )
  view = createAndShowVisualisationViewForOptions(
      visualisation: visualisation
  )

  newType = 'BarChart'
  view.$el.find("select[name='visualisation']").val(newType)
  view.updateVisualisationType()

  assert.strictEqual visualisation.get('type'), newType
)
