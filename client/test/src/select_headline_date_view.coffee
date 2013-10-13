suite('SelectHeadlineDateView')

test(".initialise queries the server for the given indicator's recent headlines", ->
  indicator = Factory.indicator()

  server = sinon.fakeServer.create()

  view = new Backbone.Views.SelectHeadlineDateView(
    indicator: indicator
  )

  assert.lengthOf server.requests, 1, "Expecting exactly one request to server"

  request = server.requests[0]
  assert.strictEqual request.url, "/api/indicators/#{indicator.get('_id')}/headlines",
    "Expected the request to be to the indicator headline path"

  view.close()
  server.restore()
)

test("After fetching headlines I see their text and year", ->
  indicator = Factory.indicator()

  headline = {
    text: "Superb", year: 2005
  }

  getHeadlinesStub = sinon.stub(Backbone.Views.SelectHeadlineDateView::, 'getHeadlines', ->
    @headlines = [headline]
  )

  view = new Backbone.Views.SelectHeadlineDateView(
    indicator: indicator
  )

  assert.match view.$el.text(), new RegExp(".*#{headline.text}.*"),
    "Expected the headline text to be visible"

  assert.match view.$el.text(), new RegExp(".*#{headline.year}.*"),
    "Expected the headline year to be visible"

  getHeadlinesStub.restore()
  view.close()
)

test(".setHeadline sets the headline on the page and calls save ", ->
  indicator = Factory.indicator()
  page = Factory.page()

  headline = {
    text: "Superb", year: 2005
  }

  getHeadlinesStub = sinon.stub(Backbone.Views.SelectHeadlineDateView::, 'getHeadlines', ->
    @headlines = [headline]
  )

  view = new Backbone.Views.SelectHeadlineDateView(
    indicator: indicator
    page: page
  )

  viewCloseSpy = sinon.spy(view, 'close')

  pretendClickEvent = {
    target: view.$el.find("[data-headline-year=#{headline.year}]")[0]
  }

  pageSaveStub = sinon.stub(page, 'save', ->)

  view.setHeadline(pretendClickEvent)

  assert.ok _.isEqual(page.get('headline'), headline),
    "Expected the page headline to be set to the selected headline"

  Helpers.assertCalledOnce pageSaveStub
  Helpers.assertCalledOnce viewCloseSpy

  getHeadlinesStub.restore()
  viewCloseSpy.restore()
)
