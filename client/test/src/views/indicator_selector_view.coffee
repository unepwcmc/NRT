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

test('When an indicator is selected, an `indicatorSelected` event is
  fired with the selected indicator', (done)->
  indicatorText = 'hats'
  indicatorAttributes = [{
    type: 'cartodb'
    title: indicatorText
  }]

  indicatorCollectionFetchStub = sinon.stub(
    Backbone.Collections.IndicatorCollection::, 'fetch', (options) ->
      @set(indicatorAttributes)
      options.success()
  )

  view = new Backbone.Views.IndicatorSelectorView()

  indicatorSelectedCallback = (indicator) ->
    assert.strictEqual indicator.get('title'), indicatorText
    done()

  view.on('indicatorSelected', indicatorSelectedCallback)

  subViews = []
  for key, subView of view.subViews
    subViews.push subView

  assert.lengthOf subViews, 1,
    "Expected the view to have an indicator sub view"
  indicatorItemSubView = subViews[0]
  indicatorItemSubView.trigger('indicatorSelected', indicatorItemSubView.indicator)

  indicatorCollectionFetchStub.restore()

  view.close()
)

test("If a current indicator is provided, I should see 'Current
  Indicator' and the indicator's title", ->

  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicator = new Backbone.Models.Indicator(
    _id: Factory.findNextFreeId('Indicator')
    title: 'A current indicator'
  )

  indicatorCollectionFetchStub = sinon.stub(
    Backbone.Collections.IndicatorCollection::, 'fetch', (options) ->
      options.success()
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
    currentIndicator: indicator
  )

  headers = view.$el.find('h3')
  assert.strictEqual $(headers[0]).text(), 'Current Indicator'

  currentIndicators = view.$el.find('.indicators.current')
  assert.match currentIndicators.text(), /A current indicator/,
    "Expected the indicator title to be in the current indicator list"

  indicatorCollectionFetchStub.restore()

  view.close()
)

test("If no current indicator is provided, I should not see a 'Current
  Indicator' header", ->

  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicatorCollectionFetchStub = sinon.stub(
    Backbone.Collections.IndicatorCollection::, 'fetch', (options) ->
      options.success()
  )

  view = new Backbone.Views.IndicatorSelectorView(
    section: section
  )

  headers = view.$el.find('h3')

  for header in headers
    assert.notEqual $(header).text(), 'Current Indicator'

  indicatorCollectionFetchStub.restore()

  view.close()
)

test('core and external indicators are listed separately', ->
  section = new Backbone.Models.Section(
    _id: Factory.findNextFreeId('Section')
  )

  indicatorAttributes = [{
    type: 'esri'
    title: 'A core indicator'
  }, {
    type: 'cartodb'
    title: 'An external indicator'
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
  assert.strictEqual $(headers[0]).text(), 'Core Indicators'
  assert.strictEqual $(headers[1]).text(), 'External Indicators'

  coreIndicators = view.$el.find('.indicators.core')
  assert.match coreIndicators.text(), /A core indicator/,
    "Expected the core indicator title to be in the core indicator list"

  externalIndicators = view.$el.find('.indicators.external')
  assert.match externalIndicators.text(), /An external indicator/,
    "Expected the external indicator title to be in the external indicator list"

  indicatorCollectionFetchStub.restore()

  view.close()
)
