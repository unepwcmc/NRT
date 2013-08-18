assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')

suite('Indicator show')

test("When given a valid indicator, I should get a 200 and see the title", (done)->
  Indicator = require('../../models/indicator').model

  indicatorTitle = "Dat test indicator"
  indicator = Indicator(title: indicatorTitle)

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.match body, new RegExp(".*#{indicatorTitle}.*")
      done()
  )
)
