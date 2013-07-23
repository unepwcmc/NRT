assert = chai.assert

createAndShowReportViewForReport = (report) ->
  view = new Backbone.Views.ReportView(report: report)
  $('#test-container').html(view.el)
  return view

suite('Report View')

test("Can see a report's title", ->
  title = "My Lovely Report"
  report = new Backbone.Models.Report(title: title)

  view = createAndShowReportViewForReport(report)
  
  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title}.*")
  )

  view.close()
)

test("Can see a report's brief", ->
  briefText = "Hey, I'm the brief"
  report = new Backbone.Models.Report(brief: briefText)

  view = createAndShowReportViewForReport(report)
  
  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{briefText}.*")
  )

  view.close()
)
