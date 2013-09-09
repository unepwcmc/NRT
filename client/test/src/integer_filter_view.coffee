assert = chai.assert

suite('Integer Filter View')

YearValueFixture =
  definition:
    fields: [
      {
        name: "year"
        type: "integer"
      }
    ]
  data:
    bounds:
      year:
        min: 2002
        max: 2005
      value:
        min: 50
        min: 400

yearValueIndicator = Factory.indicator(
  indicatorDefinition: YearValueFixture.definition
)

test('when given a visualisation with bounds it renders 2 select options', ->
  visualisation = Factory.visualisation(
    indicator: yearValueIndicator
    data: YearValueFixture.data
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
  integerFilterView.close()
)

test('when given a visualisation with filters set, the correct values are selected', ->
  visualisation = Factory.visualisation(
    indicator: yearValueIndicator
    data: YearValueFixture.data
  )
  visualisation.setFilterParameter('year', 'min', 2003)

  integerFilterView = new Backbone.Views.IntegerFilterView(
    visualisation: visualisation
    attributes:
      name: 'year'
      type: 'integer'
  )

  Helpers.renderViewToTestContainer(integerFilterView)

  assert.strictEqual(
    integerFilterView.$el.find('select[name="year-min"] option[selected]').val(),
    '2003'
  )

  integerFilterView.close()
)

test('when changing the min value it should update the visualisation
  filter parameters', ->
  visualisation = Factory.visualisation(
    indicator: yearValueIndicator
    data: YearValueFixture.data
  )

  integerFilterView = new Backbone.Views.IntegerFilterView(
    visualisation: visualisation
    attributes:
      name: 'year'
      type: 'integer'
  )

  Helpers.renderViewToTestContainer(integerFilterView)

  minYearSelect = integerFilterView.$el.find('select[name="year-min"] option[selected]')
  minYearSelect.val(2004)

  server = sinon.fakeServer.create() # Ignore triggered requests
  minYearSelect.trigger('change')
  server.restore()

  assert.strictEqual visualisation.get('filters').year.min, '2004'
)
