assert = chai.assert

factoryReport = (attributes) ->
  report = new Backbone.Models.Report
  report.set(attributes)
  return report

createAndShowReportViewForReport = (report) ->
  view = new Backbone.Views.ReportView(report: report)
  $('#test-container').html(view.el)
  return view

suite('Report View')

test("Can see a report's title", ->
  title = "My Lovely Report"
  report = factoryReport(title: title)

  view = createAndShowReportViewForReport(report)
  
  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title}.*")
  )

  view.close()
)

test("Can see a report's overview", ->
  overviewText = "Hey, I'm an overview"
  report = factoryReport(overview: overviewText)

  view = createAndShowReportViewForReport(report)
  
  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{overviewText}.*")
  )

  view.close()
)
