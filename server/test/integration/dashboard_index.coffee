assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
cheerio = require('cheerio')
async = require('async')
url = require('url')
_ = require('underscore')

appurl = (path) ->
  url.resolve('http://localhost:3001', path)


suite('All')

test('get dashboard url', (done) ->
  request.get appurl('/dashboard'), (err, res, body) ->
    assert.equal 200, res.statusCode
    done()
)

test('has latest edited reports', (done) ->
  request.get appurl('/dashboard'), (err, res, body) ->
    $ = cheerio.load(body)
    reports_count = $('body').find("section.report-indicator-list").length
    assert.isTrue reports_count > 0, 'There is at least one report on the page'
    done()
)


    


