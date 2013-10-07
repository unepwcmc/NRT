assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')

Indicator = require('../../models/indicator').model

suite('Indicator show')

test("When given a valid indicator, I should get a 200 and see the title", (done)->
  indicatorTitle = "Dat test indicator"
  indicator = new Indicator(title: indicatorTitle)

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.match body, new RegExp(".*#{indicatorTitle}.*")
      done()
  )
)

test("When given an indicator that doesn't exist, I should get a 404 response", (done)->
  indicatorId = new Indicator().id

  request.get {
    url: helpers.appurl("/indicators/#{indicatorId}")
  }, (err, res, body) ->
    if err?
      console.error err
      throw new Error(err)
    assert.equal res.statusCode, 404

    done()
)
