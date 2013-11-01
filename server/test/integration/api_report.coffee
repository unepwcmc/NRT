assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
async = require('async')
Q = require('q')

suite('API - Report')

Report = require('../../models/report').model
Indicator = require('../../models/indicator').model
Visualisation = require('../../models/visualisation').model
Narrative = require('../../models/narrative').model
Section = require('../../models/section').model

test('GET show', (done) ->
  data =
    title: "new report"

  helpers.createReport( (err, report) ->
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
  helpers.createReport( (err, report) ->
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

test('GET report with page returns page with full nested sections', (done) ->
  createReportWithSection = (err, indicator) ->
    helpers.createSection({
      indicator: indicator._id
    }, (err, section) ->
      helpers.createNarrative( {section: section._id}, (err, narrative) ->
        helpers.createVisualisation( {section: section._id}, (err, visualisation) ->
          helpers.createReport( {title: 'page report'}, (err, report) ->
            helpers.createPage(
              sections: [section]
              parent_id: report._id
              parent_type: "Report"
            ).done( (page) ->
              request.get({
                url: helpers.appurl("api/reports/#{report.id}")
                json: true
              }, (err, res, body) ->

                assert.equal res.statusCode, 200

                returnedReport = body
                assert.equal returnedReport._id, report.id
                assert.equal returnedReport.content, report.content

                assert.property returnedReport, 'page'
                returnedPage = returnedReport.page

                assert.equal page._id, returnedPage._id

                assert.property returnedPage, 'sections'
                assert.lengthOf returnedPage.sections, 1

                returnedSection = returnedPage.sections[0]
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
        )
      )
    )

  helpers.createIndicator(createReportWithSection)
)

test('DELETE report', (done) ->
  helpers.createReport( (err, report) ->
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
  helpers.createReport( (err, report) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/reports/#{report.id}")
      json: true
      body:
        title: new_title
    }, (err, res, body) ->

      assert.equal res.statusCode, 200

      Report.count( (err, count)->
        assert.equal count, 1
        Report
          .findOne(report.id)
          .exec( (err, report) ->
            assert.equal report.title, new_title
            done()
          )
      )

    )
  )
)

test('PUT report succeeds with an _id sent', (done) ->
  helpers.createReport( (err, report) ->
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
