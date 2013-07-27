assert = chai.assert

createAndShowReportListView = (reports) ->
  view = new Backbone.Views.ReportListView(reports: reports)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Report Index')

test("List titles of all reports", ->
  title1 = 'Lovely, lovely report'
  title2 = 'Horrible, horrible report'

  reports = new Backbone.Collections.ReportCollection([{
    title: title1
  },{
    title: title2
  }])

  view = createAndShowSectionNavigationView(reports)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title1}.*")
  )

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title2}.*")
  )
  view.close()
)

test("Can see creator and completed_at date for each report")
test("Can see if report is bookmarked/favourited")
test("Can navigate to report view")
