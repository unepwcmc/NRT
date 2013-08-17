assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')

suite('API - Indicator')

test('api/indicators should list the indicators', (done) ->
  helpers.createIndicatorModels([
    {
      title: 'indicator 1'
    }, {
      title: 'indicator 2'
    }
  ]).success((indicators)->
    request.get {
      url: helpers.appurl('/api/indicators')
    }, (err, res, body) ->
      assert.equal res.statusCode, 200
      indicatorJson = JSON.parse body

      assert.equal indicatorJson.length, indicators.length
      jsonTitles = _.map(indicatorJson, (indicator)->
        indicator.title
      )
      indicatorTitles = _.map(indicators, (indicator)->
        indicator.title
      )

      assert.deepEqual jsonTitles, indicatorTitles
      
      done()
  ).error((error) ->
    console.error error
    throw "Unable to create indicators"
  )
)
