assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

suite('API - Indicator')

Indicator = require('../../models/indicator').model

test('when posting it creates a indicator', (done) ->
  data =
    title: "new indicator"

  request.post({
    url: helpers.appurl('api/indicator/')
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

    callback(indicator)


test("show returns a indicator's title", (done) ->
  createIndicator( (indicator) ->
    request.get({
      url: helpers.appurl("api/indicator/#{indicator.id}")
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

test('index lists all indicators', (done) ->
  createIndicator( (indicator) ->
    request.get({
      url: helpers.appurl("api/indicator")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      indicators = body
      assert.equal indicators[0]._id, indicator.id
      assert.equal indicators[0].content, indicator.content

      done()
    )
  )
)

test('can delete a indicator', (done) ->
  createIndicator( (indicator) ->
    request.del({
      url: helpers.appurl("api/indicator/#{indicator.id}")
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

test('can update a indicator', (done) ->
  createIndicator( (indicator) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/indicator/#{indicator.id}")
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
