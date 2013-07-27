assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
_ = require('underscore')

suite('Indicator index')

createIndicatorModels = (attributes) ->
  successCallback = errorCallback = promises = null

  Indicator = require('../../models/indicator')
  createFunctions = _.map(attributes, (attributeSet) ->
    return (callback) ->
      return Indicator.create(attributeSet)
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

test("With a series of indicators, I should see their titles", (done) ->
  createIndicatorModels([
    {title: 'indicator 1'}, {title: 'indicator 2'}
  ]).success((indicators)->
    request.get {
      url: helpers.appurl('/indicators')
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      for indicator in indicators
        assert.match body, new RegExp(".*#{indicator.title}.*")

      done()
  ).error((error) ->
    console.error error
    throw "Unable to create indicators"
  )
)

