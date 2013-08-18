assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')

suite('API - Indicator')

Indicator = require('../../models/indicator').model

test('POST create', (done) ->
  data =
    title: "new indicator"

  request.post({
    url: helpers.appurl('api/indicators/')
    json: true
    body: data
  },(err, res, body) ->
    id = body.id

    assert.equal res.statusCode, 201

    Indicator
      .findOne(id)
      .exec( (err, indicator) ->
        assert.equal indicator.title, data.title
        done()
      )
  )
)

createIndicator = (callback) ->
  indicator = new Indicator(
    title: "new indicator"
  )

  indicator.save (err, indicator) ->
    if err?
      throw 'could not save indicator'

    callback(null, indicator)

test("GET show", (done) ->
  createIndicator( (err, indicator) ->
    request.get({
      url: helpers.appurl("api/indicators/#{indicator.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedIndicator = body
      assert.equal reloadedIndicator._id, indicator.id
      assert.equal reloadedIndicator.content, indicator.content

      done()
    )
  )
)

test('GET index', (done) ->
  async.series([createIndicator, createIndicator], (err, indicators) ->
    request.get({
      url: helpers.appurl("api/indicators")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      indicatorJson = body

      assert.equal indicatorJson.length, indicators.length
      jsonTitles = _.map(indicatorJson, (indicator)->
        indicator.title
      )
      indicatorTitles = _.map(indicators, (indicator)->
        indicator.title
      )

      assert.deepEqual jsonTitles, indicatorTitles
      done()
    )
  )
)

test('DELETE indicator', (done) ->
  createIndicator( (err, indicator) ->
    request.del({
      url: helpers.appurl("api/indicators/#{indicator.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204

      Indicator.count( (err, count)->
        unless err?
          assert.equal 0, count
          done()
      )
    )
  )
)

test('PUT indicator', (done) ->
  createIndicator( (err, indicator) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/indicators/#{indicator.id}")
      json: true
      body:
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Indicator
        .findOne(id)
        .exec( (err, indicator) ->
          assert.equal indicator.title, new_title
          done()
        )
    )
  )
)

test('PUT indicator does not fail when an _id is given', (done) ->
  createIndicator( (err, indicator) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/indicators/#{indicator.id}")
      json: true
      body:
        _id: indicator.id
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Indicator
        .findOne(id)
        .exec( (err, indicator) ->
          assert.equal indicator.title, new_title
          done()
        )
    )
  )
)
