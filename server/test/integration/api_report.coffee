assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
async = require('async')

suite('API - Report')

Report = require('../../models/report').model

test('when posting it creates a report', (done) ->
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

createReport = (attributes, callback) ->
  if arguments.length == 1
    callback = attributes
    attributes = undefined

  report = new Report(attributes || title: "new report")

  report.save (err, report) ->
    if err?
      throw 'could not save report'

    callback(report)


test("show returns a report's data", (done) ->
  createReport( (report) ->
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

test('index lists all reports', (done) ->
  createReport( (report) ->
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

test('GET / returns full nested sections')
test('GET /report/<id> returns full nested sections')

createSection = (attributes, callback) ->
  Section = require('../../models/section.coffee').model

  if arguments.length == 1
    callback = attributes
    attributes = undefined

  section = new Section(attributes || content: "a section")

  section.save (err, section) ->
    if err?
      throw 'could not save section'

    callback(null, section)

test('nesting a section in a report with existing sections', (done) ->
  createReportWithSection = (err, results) ->
    section = results[0]
    newSection = results[1]

    createReport(
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

test('nesting a section in a report', (done) ->
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

test('can delete a report', (done) ->
  createReport( (report) ->
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

test('can update a report', (done) ->
  createReport( (report) ->
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
