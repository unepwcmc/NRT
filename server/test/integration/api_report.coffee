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

  helpers.createReport( (report) ->
    request.get({
      url: helpers.appurl("api/reports/#{report.id}")
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
      url: helpers.appurl("api/reports")
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

    helpers.createSection({
      indicators: [indicator]
      narrative: narrative
      visualisation: visualisation
    }, (err, section) ->
      helpers.createReport({sections: [section]}, (report) ->
        request.get({
          url: helpers.appurl("api/reports/#{report.id}")
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

          assert.property returnedSection, 'indicators'
          assert.equal indicator._id, returnedSection.indicators[0]._id

          assert.property returnedSection, 'visualisation'
          assert.equal visualisation._id, returnedSection.visualisation._id

          done()
        )
      )
    )

  async.series([
    helpers.createIndicator, helpers.createNarrative, helpers.createVisualisation
  ], createReportWithSection)
)

test('PUT nesting a section in a report with existing sections', (done) ->
  createReportWithSection = (err, results) ->
    section = results[0]
    newSection = results[1]

    helpers.createReport(
      {title: "A report", sections: [section]},
      (report) ->
        updateAttributes = report.toObject()
        updateAttributes.sections.push newSection.toObject()

        request.put({
          url: helpers.appurl("/api/reports/#{report.id}")
          json: true
          body: updateAttributes
        }, (err, res, body) ->
          id = body.id

          assert.equal res.statusCode, 200
          assert.lengthOf body.sections, 2

          assert.equal body.sections[1]._id, newSection._id

          done()
        )
    )

  async.series([helpers.createSection, helpers.createSection], createReportWithSection)
)

test('POST create - nesting a section in a report', (done) ->
  helpers.createSection( (err, section) ->
    data =
      title: "new report"
      sections: [section.toObject()]

    request.post({
      url: helpers.appurl('api/reports/')
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
      url: helpers.appurl("api/reports/#{report.id}")
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
      url: helpers.appurl("/api/reports/#{report.id}")
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

test('PUT report succeeds with an _id sent', (done) ->
  helpers.createReport( (report) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/reports/#{report.id}")
      json: true
      body:
        _id: report.id
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
