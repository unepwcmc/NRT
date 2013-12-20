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

test('.delete destroys the Visualisation model and unsets the assocation
on the parent section', (done)->
  section = Factory.section()
  visualisation = Factory.visualisation(
    type: "Table"
  )
  section.set('visualisation', visualisation)
  visualisationDestroySpy = sinon.spy(visualisation, 'destroy')

  server = sinon.fakeServer.create()
  server.respondWith("DELETE", new RegExp("/api/visualisations/.*"),
    [204, { "Content-Type": "application/json" }, JSON.stringify({message:'Deleted'})]
  )

  event =
    stopPropagation: sinon.spy()

  view = new Backbone.Views.VisualisationView(visualisation: visualisation)

  try
    view.delete(event)
    server.respond()

    assert.strictEqual visualisationDestroySpy.callCount, 1,
      "Expected visualisation.destroy() to be called once"

    assert.strictEqual event.stopPropagation.callCount, 1,
      "Expected event.stopPropagation to be called once"

    assert.isNull section.get('visualisation'),
      "Expected the parent section to have its association unset"

    view.close()
    done()
  catch err
    done(err)
  finally
    server.restore()
)

test('Clicking .delete-visualisation calls the delete function', ->
  visualisation = Factory.visualisation(
    type: "Table"
  )

  visualisationDestroyStub = sinon.stub(visualisation, 'destroy', ->)

  viewDeleteStub = sinon.stub(Backbone.Views.VisualisationView::, 'delete', ->)
  view = new Backbone.Views.VisualisationView(visualisation: visualisation)

  view.render()

  view.$el.find('.delete-visualisation').trigger('click')

  try
    assert.strictEqual viewDeleteStub.callCount, 1,
      "Expected view.delete() to be called once"
  finally
    view.close()
    viewDeleteStub.restore()
)
