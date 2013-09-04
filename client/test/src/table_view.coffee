assert = chai.assert

suite('Table View')

test('Should render visualisation data into a table', ->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  visualisation.set('data', results: [{
      year: 2015
      value: 10
    },{
      year: 2014
      value: 8
  }])

  indicator = visualisation.get('indicator')
  indicator.set(
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
    title: 'An indicatr'
  )

  view = new Backbone.Views.TableView(visualisation: visualisation)
  Helpers.renderViewToTestContainer(view)

  assert.strictEqual(
    $('#test-container').find('table caption').text(),
    indicator.get('title')
  )

  headerText = $('#test-container').find('table thead').text()

  assert.match headerText, new RegExp(".*#{visualisation.getXAxis()}.*")
  assert.match headerText, new RegExp(".*#{visualisation.getYAxis()}.*")

  bodyText = $('#test-container').find('table tbody').text()

  assert.match bodyText, /.*2015.*/
  assert.match bodyText, /.*10.*/
)
