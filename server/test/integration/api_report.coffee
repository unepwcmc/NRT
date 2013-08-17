assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

suite('API - Report')

test('create', (done) ->
  data =
    title: "new report"

  Report = require('../../models/report')
  request.post({
    url: helpers.appurl('api/report/')
    json: true
    body: data
  },(err, res, body) ->
    id = body.id

    assert.equal res.statusCode, 201

    Report.find(id).success((report) ->
      assert.equal report.title, data.title
      done()
    )
  )
)

test('returns full nested sections')

test('update', (done) ->
  data =
    title: "test report title 1"

  Report = require('../../models/report')
  Report.create(data).success((report) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/report/#{report.id}")
      json: true
      body:
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Report.find(id).success((report) ->
        assert.equal report.title, new_title
        done()
      )
    )
  )
)
