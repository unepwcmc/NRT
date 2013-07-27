assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
_ = require('underscore')

appurl = (path) ->
  url.resolve('http://localhost:3001', path)

suite('Report index')

test("Can navigate to Dashboard, Reports, Indicators and Bookmarks", (done) ->
  request.get {
    url: appurl('/reports')
  }, (err, res, body) ->
    assert.match body, new RegExp(".*href=\"/reports\".*")
    assert.match body, new RegExp(".*href=\"/indicators\".*")
    assert.match body, new RegExp(".*href=\"/bookmarks\".*")
    assert.match body, new RegExp(".*href=\"/dashboard\".*")

    assert.equal res.statusCode, 200
    done()
)

