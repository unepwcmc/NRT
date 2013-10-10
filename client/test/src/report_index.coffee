assert = chai.assert

createAndShowReportListView = (reports) ->
  view = new Backbone.Views.ReportListView(reports: reports)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Report Index')

test("List titles of all reports", ->
  title = 'Lovely, lovely report'

  reports = [{
    title: title
  }]

  view = createAndShowReportListView(reports)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title}.*")
  )

  view.close()
)

test("Shows message when no reports are available")
test("Can see the formatted completed_at datetime")

test("Can see if report is bookmarked/favourited", ->
  reports = [{
    bookmarked: true
  }]

  view = createAndShowReportListView(reports)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*Bookmarked.*")
  )

  view.close()
)

test("Can see report period", ->
  time_period = '3030'

  reports = [{
    period: time_period
  }]

  view = createAndShowReportListView(reports)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{time_period}.*")
  )

  view.close()
)

test("Can navigate to report view", ->
  id = 1

  reports = [{
    _id: id
    title: "Kanye West's Kanye Quest"
  }]

  view = createAndShowReportListView(reports)

  assert.match(
    $('#test-container').html(),
    new RegExp(".*/reports/#{id}.*")
  )

  view.close()
)
