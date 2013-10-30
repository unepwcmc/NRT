assert = chai.assert

createAndShowVisualisationViewForOptions = (options) ->
  view = new Backbone.Views.ReportEditVisualisationView(options)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('ReportEditVisualisationView')

test("Shows the given indicator title", ->
  indicatorTitle = "my lovely indicator"
  indicator = Factory.indicator()
  indicator.set('title', indicatorTitle)

  section = new Backbone.Models.Section(
    indicator: indicator
  )

  view = createAndShowVisualisationViewForOptions(
    visualisation: Factory.visualisation(
      indicator: indicator
      section: section
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
    visualisation: Factory.visualisation()
  )

  callback = sinon.spy()
  view.on('close', callback)

  view.closeModal()
  assert(callback.called, "Close event not fired")
)

test("When given a visualisation with type BarChart,
  it renders a BarChartView subView", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: Factory.visualisation(
      type: "BarChart"
    )
  )
     
  assert.ok Helpers.viewHasSubViewOfClass(view, "BarChartView")

  view.close()
)

test("When given a visualisation with type Map,
  it renders a MapView subView", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: Factory.visualisation(
      type: "Map"
    )
  )

  Helpers.viewHasSubViewOfClass view, "MapView"

  view.close()
)

test("When given a visualisation with type Table,
  it renders a TableView subView", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: Factory.visualisation(
      type: "Table"
    )
  )

  Helpers.viewHasSubViewOfClass view, "TableView"

  view.close()
)

test("I see the visualisation type selected", ->
  view = createAndShowVisualisationViewForOptions(
    visualisation: Factory.visualisation(
      type: "Map"
    )
  )

  assert.strictEqual view.$el.find('option:selected').val(), "Map"
  view.close()
)

test(".updateVisualisationType should set the visualisation type", ->
  visualisation = Factory.visualisation(
    type: "Map"
  )
  view = createAndShowVisualisationViewForOptions(
    visualisation: visualisation
  )

  newType = 'BarChart'
  view.$el.find("select[name='visualisation']").val(newType)
  view.updateVisualisationType()

  assert.strictEqual visualisation.get('type'), newType
  view.close()
)
