assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

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

createReport = (callback) ->
  report = new Report(
    title: "new report"
  )

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

test('returns full nested sections')

test('can delete a report', (done) ->
  createReport( (report) ->
    request.del({
      url: helpers.appurl("api/report/#{report.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204
      done()
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
