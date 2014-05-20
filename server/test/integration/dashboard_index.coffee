assert = require('chai').assert
helpers = require '../helpers'
request = require('request')

suite('Dashboard')

test('GET index', (done) ->
  request.get helpers.appurl('/dashboard'), (err, res, body) ->
    assert.equal 200, res.statusCode
    done()
)

test('GET index has latest edited reports listed', (done) ->
  reports = [
    {
      title: 'Report 1'
      introduction: 'The intro for the first report'
    }, {
      title: 'Report 2'
      description: 'The intro for the second report'
    }
  ]
  helpers.createReportModels(reports)
  .then((reports)->
    request.get helpers.appurl('/dashboard'), (err, res, body) ->
      for report in reports
        assert.match body, new RegExp(".*#{report.title}.*")

      done()
  ).catch((error) ->
    console.error error
    throw "Unable to create reports"
  )
)
