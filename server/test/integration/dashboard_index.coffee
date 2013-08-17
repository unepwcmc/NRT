assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
cheerio = require('cheerio')
async = require('async')
url = require('url')
_ = require('underscore')


appurl = (path) ->
  url.resolve('http://localhost:3001', path)

# TODO: copyed from James's http://goo.gl/8Tu6tx
# Would be good to move in a more general helper.
createReportModels = (attributes) ->
  successCallback = errorCallback = promises = null

  Report = require('../../models/report')
  createFunctions = _.map(attributes, (attributeSet) ->
    return (callback) ->
      return Report.create(attributeSet)
        .success((indicators)->
          callback(null, indicators)
        ).error(callback)
  )

  async.parallel(
    createFunctions,
    (error, results) ->
      if error?
        errorCallback(error, results) if errorCallback?
      else
        successCallback(results) if successCallback?
  )

  promises = {
    success: (callback)->
      successCallback = callback
      return promises
    error: (callback)->
      errorCallback = callback
      return promises
  }
  return promises


suite('Page load')

test('get dashboard url', (done) ->
  request.get appurl('/dashboard'), (err, res, body) ->
    assert.equal 200, res.statusCode
    done()
)

suite('Reports section')

test('has latest edited reports listed', (done) ->
  createReportModels([
    {
      title: 'Report 1'
      introduction: 'The intro for the first report'
    }, {
      title: 'Report 2'
      description: 'The intro for the second report'
    }
  ]).success((reports)->
    request.get appurl('/dashboard'), (err, res, body) ->
      $ = cheerio.load(body)
      reports_count = $('body').find("section.report-indicator-list").length
      assert.isTrue reports_count > 0, 'There is at least one report on the page'
      done()
  ).error((error) ->
    console.error error
    throw "Unable to create reports"
  )
)
