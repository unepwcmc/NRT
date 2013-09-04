assert = chai.assert

suite('Integer Filter View')

test('when given a visualisation with bounds it renders 2 select options', ->
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
    data:
      bounds:
        year:
          min: 2002
          max: 2005
        value:
          min: 50
          min: 400
  )

  integerFilterView = new Backbone.Views.IntegerFilterView(
    visualisation: visualisation
    attributes:
      name: 'year'
      type: 'integer'
  )

  Helpers.renderViewToTestContainer(integerFilterView)

  assert.strictEqual(
    integerFilterView.$el.find('select[name="year-min"] option[selected]').val(),
    '2002'
  )

  assert.strictEqual(
    integerFilterView.$el.find('select[name="year-max"] option[selected]').val(),
    '2005'
  )
)
