assert = chai.assert

suite('Dashboard')

test("Can view my work-in-progress")
test("Can view my notifications")
test("Can view my recent reports")
test("Can view my recent indicators")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")

suite('Dashboard: notifications')
test("Can see requests for me to write sections")
test("Requests to write sections have title and requester and date")

suite('Dashboard: work-in-progress')

suite('Dashboard: reports')

suite('Dashboard: indicators')

assert = chai.assert

suite('Indicator Index')

test("List titles of all indicators")
test("Can see owner for each report")
test("Can see latest data available for each report")
test("Can see latest data updated_at for each report")
test("Can see if indicator is bookmarked/favourited")
test("Can navigate to all related reports")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")

assert = chai.assert

suite('Report Index')

test("List titles of all reports")
test("Can see creator and completed_at date for each report")
test("Can see if report is bookmarked/favourited")
test("Can navigate to report view")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")

assert = chai.assert

suite('Backbone.Models.Report')

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

test("If report cover image exists, can view")
test("If report cover image doesn't exist, can see no image")

test("Report sections views are rendered", ->
  section = new Backbone.Models.Section()
  report = new Backbone.Models.Report(sections: [section])

  view = createAndShowReportViewForReport(report)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "SectionView"
      subViewExists = true

  assert subViewExists

  view.close()
)

test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")

assert = chai.assert

createAndShowSectionViewForSection = (section) ->
  view = new Backbone.Views.SectionView(section: section)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Section View')

test("Can see the section title", ->
  title = "My Lovely Section"
  section = new Backbone.Models.Section(title: title)

  view = createAndShowSectionViewForSection(section)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title}.*")
  )

  view.close()
)

test("Can see the section visualisation")
test("Can see the section narrative")
test("Can edit the section")
test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
