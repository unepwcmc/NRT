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

test(".getFieldData should add subViewName to the indicator field list", ->
  visualisation = new Backbone.Models.Visualisation(
    indicator: Helpers.factoryIndicator(
      indicatorDefinition:
        fields: [
          {
            name: "year"
            type: "integer"
          }
        ]
    )
  )

  view = new Backbone.Views.VisualisationFilterView(visualisation: visualisation)

  fieldData = view.getFieldData()
  assert.strictEqual fieldData[0].subViewName, "IntegerFilterView"

  view.close()
)

test("Given an indicator with a field of type 'integer', it should 
  create an IntegerFilterView subView", ->
  dummyBounds = {
    year: {min:5, max: 6}
    value: {min:5, max: 6}
  }
  visualisation = Helpers.factoryVisualisationWithIndicator(
    data:
      results: []
      bounds: dummyBounds
    indicator: Helpers.factoryIndicator(
      indicatorDefinition: yearValueIndicatorDefinition
    )
  )

  view = new Backbone.Views.VisualisationFilterView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  assert.ok Helpers.viewHasSubViewOfClass(view, "IntegerFilterView")

  view.close()
)
