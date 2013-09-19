assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
_ = require('underscore')

appurl = (path) ->
  url.resolve('http://localhost:3001', path)

suite('Report index')

test("GET show", (done) ->
  helpers.createReport( (report) ->
    request.get {
      url: appurl("/reports/#{report.id}")
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.match body, new RegExp(".*#{report.title}.*")

      done()
  )
)

test("Can navigate to Dashboard, Reports, and Indicators", (done) ->
  request.get {
    url: appurl('/reports')
  }, (err, res, body) ->
    assert.match body, new RegExp(".*href=\"/reports\".*")
    assert.match body, new RegExp(".*href=\"/themes\".*")
    assert.match body, new RegExp(".*href=\"/dashboard\".*")

    assert.equal res.statusCode, 200
    done()
)

