assert = chai.assert

suite('IndicatorSelectorView')

test('Renders a list of indicators', ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  server = sinon.fakeServer.create()

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  assert.equal(
    server.requests[0].url,
    "/api/indicators"
  )

  indicatorTitle = 'An indicator'
  Helpers.SinonServer.respondWithJson.call(server, [{_id: 1, title: indicatorTitle}])
  server.restore()

  Helpers.renderViewToTestContainer(view)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{indicatorTitle}.*")
  )

  view.close()
)

test('Primary and secondary indicators are listed separately', ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicatorAttributes = [{
    type: 'esri'
    title: 'A primary indicator'
  }, {
    type: 'cartodb'
    title: 'A secondary indicator'
  }]

  indicatorCollectionFetchStub = sinon.stub(
    Backbone.Collections.IndicatorCollection::, 'fetch', (options) ->
      @set(indicatorAttributes)
      options.success()
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  headers = view.$el.find('h3')
  assert.lengthOf headers, 2
  assert.strictEqual $(headers[0]).text(), 'Primary Indicators'
  assert.strictEqual $(headers[1]).text(), 'Secondary Indicators'

  primaryIndicators = view.$el.find('.indicators.primary')
  assert.match primaryIndicators.text(), /A primary indicator/,
    "Expected the primary indicator title to be in the primary indicator list"

  secondaryIndicators = view.$el.find('.indicators.secondary')
  assert.match secondaryIndicators.text(), /A secondary indicator/,
    "Expected the secondary indicator title to be in the secondary indicator list"

  indicatorCollectionFetchStub.restore()

  view.close()
)
