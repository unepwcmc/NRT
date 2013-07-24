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

suite('Section Model')

test("Has many narratives", ->
  section = new Backbone.Models.Section()
  assert.equal 'NarrativeCollection', section.get('narratives').constructor.name
)

test("Has many visualisations", ->
  section = new Backbone.Models.Section()
  assert.equal 'VisualisationCollection', section.get('visualisations').constructor.name
)

test("When initialised with an array of visualisations, creates a visualisation collection", ->
  visualisations = [new Backbone.Models.Visualisation()]
  section = new Backbone.Models.Section(visualisations: visualisations)
  assert.equal section.get('visualisations').constructor.name, 'VisualisationCollection'
)

test("When initialised with an array of narratives, creates a narrative collection", ->
  narratives = [new Backbone.Models.Narrative()]
  section = new Backbone.Models.Section(narratives: narratives)
  assert.equal section.get('narratives').constructor.name, 'NarrativeCollection'
)

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

test("Can see the section visualisation", ->
  visualisation = new Backbone.Models.Visualisation()
  section = new Backbone.Models.Section(visualisations: [visualisation])

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "VisualisationView"
      subViewExists = true

  assert subViewExists

  view.close()
)

test("Can see the section narrative", ->
  narrative = new Backbone.Models.Narrative()
  section = new Backbone.Models.Section(narratives: [narrative])

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "NarrativeView"
      subViewExists = true

  assert subViewExists

  view.close()
)
test("Can edit the section")
test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
