assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
_ = require('underscore')

suite('Indicator index')

test("With a series of indicators, I should see their titles and description", (done) ->
  helpers.createIndicatorModels([
    {
      title: 'indicator 1'
      description: 'The description for the first indicator'
    }, {
      title: 'indicator 2'
      description: 'Description for another indicator'
    }
  ]).success((indicators)->
    request.get {
      url: helpers.appurl('/indicators')
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      for indicator in indicators
        assert.match body, new RegExp(".*#{indicator.title}.*")
        assert.match body, new RegExp(".*#{indicator.description}.*")

      done()
  ).error((error) ->
    console.error error
    throw "Unable to create indicators"
  )
)

