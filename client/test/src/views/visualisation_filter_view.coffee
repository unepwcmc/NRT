assert = chai.assert

suite('Visualisation Filter View')

yearValueIndicatorDefinition =
  fields: [
    {
      "name": "year"
      "type": "integer"
    },
    {
      "name": "value"
      "type": "integer"
    }
  ]

test(".getFieldData returns subViews for types where subViews exists", ->
  visualisation = new Backbone.Models.Visualisation(
    indicator: Factory.indicator(
      indicatorDefinition:
        fields: [{
          name: "year"
          type: "integer"
        },{
          name: "value"
          type: "text"
        }]
    )
  )

  view = new Backbone.Views.VisualisationFilterView(visualisation: visualisation)

  fieldData = view.getFieldData()
  assert.lengthOf fieldData, 1
  assert.strictEqual fieldData[0].subViewName, "IntegerFilterView"

  view.close()
)

test("Given an indicator with a field of type 'integer', it should 
  create an IntegerFilterView subView", ->
  dummyBounds = {
    year: {min:5, max: 6}
    value: {min:5, max: 6}
  }
  visualisation = Factory.visualisation(
    data:
      results: []
      bounds: dummyBounds
    indicator: Factory.indicator(
      indicatorDefinition: yearValueIndicatorDefinition
    )
  )

  view = new Backbone.Views.VisualisationFilterView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  assert.ok Helpers.viewHasSubViewOfClass(view, "IntegerFilterView")

  view.close()
)
