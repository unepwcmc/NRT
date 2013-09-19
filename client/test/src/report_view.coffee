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

test("If report cover image exists, can view image and caption", ->
  imgLocation = "chewbacca.jpg"
  imgCaption  = "Chewie, 2013"
  report = new Backbone.Models.Report(img: imgLocation, imgCaption: imgCaption)

  view = createAndShowReportViewForReport(report)

  assert.match(
    $('#test-container').find('header').css('background-image'),
    new RegExp(".*#{imgLocation}.*")
  )

  assert.match(
    $('#test-container').find('header').text(),
    new RegExp(".*#{imgCaption}.*")
  )

  view.close()
)

test("If report cover image doesn't exist, can see no image", ->
  imgLocation = ""
  report = new Backbone.Models.Report(img: imgLocation)

  view = createAndShowReportViewForReport(report)

  assert $('#test-container').find('header.report-header').length == 0

  view.close()
)

test("Report sections views are rendered", ->
  section = new Backbone.Models.Section()
  report = new Backbone.Models.Report(sections: [section])

  view = createAndShowReportViewForReport(report)

  assert.ok Helpers.viewHasSubViewOfClass(view, 'SectionView')

  view.close()
)

test(".addSection adds a section to the report", ->
  report = Factory.report()
  reportView = new Backbone.Views.ReportView(report: report)

  assert.equal report.get('sections').length, 0

  reportView.addSection()

  assert.equal report.get('sections').length, 1
  assert.strictEqual report.get('sections').at(0).get('parent').get('cid'), report.get('cid')
  assert.equal report.get('sections').at(0).get('type'), "Section"
)

test(".addChapter adds a section with type 'chapter' to the report", ->
  report = Factory.report()
  reportView = new Backbone.Views.ReportView(report: report)

  assert.equal report.get('sections').length, 0

  reportView.addChapter()

  assert.equal report.get('sections').length, 1
  assert.strictEqual report.get('sections').at(0).get('parent').get('cid'), report.get('cid')
  assert.equal report.get('sections').at(0).get('type'), "Chapter"
)

test("Given a report with a section of type 'Chapter',
  it renders a ChapterView sub view", ->
  report = Factory.report(
    sections: Factory.section(type: 'Chapter')
  )

  reportView = new Backbone.Views.ReportView(report: report)

  reportView.render()
  assert.ok Helpers.viewHasSubViewOfClass(reportView, 'ChapterView')

  reportView.close()
)
