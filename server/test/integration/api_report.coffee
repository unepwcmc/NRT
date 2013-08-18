assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
async = require('async')

suite('API - Report')

Report = require('../../models/report').model
Indicator = require('../../models/indicator').model
Visualisation = require('../../models/visualisation').model
Narrative = require('../../models/narrative').model
Section = require('../../models/section').model

test('POST create', (done) ->
  data =
    title: "new report"

  request.post({
    url: helpers.appurl('api/report/')
    json: true
    body: data
  },(err, res, body) ->
    id = body.id

    assert.equal res.statusCode, 201

    Report
      .findOne(id)
      .exec( (err, report) ->
        assert.equal report.title, data.title
        done()
      )
  )
)

createSection = (attributes, callback) ->
  if arguments.length == 1
    callback = attributes
    attributes = undefined

  section = new Section(attributes || content: "a section")

  section.save (err, section) ->
    if err?
      throw 'could not save section'

    callback(null, section)

createIndicator = (callback) ->
  indicator = new Indicator(
    title: "new indicator"
  )

  indicator.save (err, indicator) ->
    if err?
      throw 'could not save indicator'

    callback(null, indicator)

createVisualisation = (callback) ->
  visualisation = new Visualisation(
    data: "new visualisation"
  )

  visualisation.save (err, Visualisation) ->
    if err?
      throw 'could not save visualisation'

    callback(null, visualisation)

createNarrative = (callback) ->
  narrative = new Narrative(
    content: "new narrative"
  )

  narrative.save (err, narrative) ->
    if err?
      throw 'could not save narrative'

    callback(null, narrative)


test("GET show", (done) ->
  helpers.createReport( (report) ->
    request.get({
      url: helpers.appurl("api/report/#{report.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedReport = body
      assert.equal reloadedReport._id, report.id
      assert.equal reloadedReport.content, report.content

      done()
    )
  )
)

test('GET index', (done) ->
  helpers.createReport( (report) ->
    request.get({
      url: helpers.appurl("api/report")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reports = body
      assert.equal reports[0]._id, report.id
      assert.equal reports[0].content, report.content

      done()
    )
  )
)

test('GET report returns full nested sections', (done) ->
  createReportWithSection = (err, results) ->
    indicator = results[0]
    narrative = results[1]
    visualisation = results[2]

    createSection({
      indicator: indicator
      narrative: narrative
      visualisation: visualisation
    }, (err, section) ->
      helpers.createReport({sections: [section._id]}, (report) ->
        request.get({
          url: helpers.appurl("api/report/#{report.id}")
          json: true
        }, (err, res, body) ->
          assert.equal res.statusCode, 200

          returnedReport = body
          assert.equal returnedReport._id, report.id
          assert.equal returnedReport.content, report.content

          assert.property returnedReport, 'sections'
          assert.lengthOf returnedReport.sections, 1

          returnedSection = returnedReport.sections[0]
          assert.equal section._id, returnedSection._id

          assert.property returnedSection, 'narrative'
          assert.equal narrative._id, returnedSection.narrative._id

          assert.property returnedSection, 'indicator'
          assert.equal indicator._id, returnedSection.indicator._id

          assert.property returnedSection, 'visualisation'
          assert.equal visualisation._id, returnedSection.visualisation._id

          done()
        )
      )
    )

  async.series([
    createIndicator, createNarrative, createVisualisation
  ], createReportWithSection)
)

test('PUT nesting a section in a report with existing sections', (done) ->
  createReportWithSection = (err, results) ->
    section = results[0]
    newSection = results[1]

    helpers.createReport(
      {title: "A report", sections: [section]},
      (report) ->
        request.put({
          url: helpers.appurl("/api/report/#{report.id}")
          json: true
          body:
            sections: [newSection._id]
        }, (err, res, body) ->
          id = body.id

          assert.equal res.statusCode, 200
          assert.lengthOf body.sections, 2

          assert.equal body.sections[1]._id, newSection._id

          done()
        )
    )

  async.series([createSection, createSection], createReportWithSection)
)

test('POST create - nesting a section in a report', (done) ->
  createSection( (err, section) ->
    data =
      title: "new report"
      sections: [section._id]

    request.post({
      url: helpers.appurl('api/report/')
      json: true
      body: data
    },(err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 201

      assert.property body, 'sections'
      assert.lengthOf body.sections, 1
      assert section._id, body.sections[0]._id

      Report
        .findOne(id)
        .exec( (err, report) ->
          assert.equal report.title, data.title
          done()
        )
    )
  )
)

test('DELETE report', (done) ->
  helpers.createReport( (report) ->
    request.del({
      url: helpers.appurl("api/report/#{report.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204

      Report.count( (err, count)->
        unless err?
          assert.equal 0, count
          done()
      )
    )
  )
)

test('PUT report', (done) ->
  helpers.createReport( (report) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/report/#{report.id}")
      json: true
      body:
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Report
        .findOne(id)
        .exec( (err, report) ->
          assert.equal report.title, new_title
          done()
      )
    )
  )
)
