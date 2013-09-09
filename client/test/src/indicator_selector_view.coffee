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
