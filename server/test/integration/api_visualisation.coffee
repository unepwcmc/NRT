assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

suite('API - Visualisation')

Visualisation = require('../../models/visualisation').model

test('when posting it creates a visualisation', (done) ->
  data =
    data: "new visualisation"

  request.post({
    url: helpers.appurl('api/visualisation/')
    json: true
    body: data
  },(err, res, body) ->
    id = body.id

    assert.equal res.statusCode, 201

    Visualisation
      .findOne(id)
      .exec( (err, visualisation) ->
        assert.equal visualisation.data, data.data
        done()
      )
  )
)

createVisualisation = (callback) ->
  visualisation = new Visualisation(
    data: "new visualisation"
  )

  visualisation.save (err, visualisation) ->
    if err?
      throw 'could not save visualisation'

    callback(visualisation)


test("show returns a visualisation's data", (done) ->
  createVisualisation( (visualisation) ->
    request.get({
      url: helpers.appurl("api/visualisation/#{visualisation.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedVisualisation = body
      assert.equal reloadedVisualisation._id, visualisation.id
      assert.equal reloadedVisualisation.content, visualisation.content

      done()
    )
  )
)

test('index lists all visualisations', (done) ->
  createVisualisation( (visualisation) ->
    request.get({
      url: helpers.appurl("api/visualisation")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      visualisations = body
      assert.equal visualisations[0]._id, visualisation.id
      assert.equal visualisations[0].content, visualisation.content

      done()
    )
  )
)

test('returns full nested sections')

test('can delete a visualisation', (done) ->
  createVisualisation( (visualisation) ->
    request.del({
      url: helpers.appurl("api/visualisation/#{visualisation.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204

      Visualisation.count( (err, count)->
        unless err?
          assert.equal 0, count
          done()
      )
    )
  )
)

test('can update a visualisation', (done) ->
  createVisualisation( (visualisation) ->
    new_data = "Updated data"
    request.put({
      url: helpers.appurl("/api/visualisation/#{visualisation.id}")
      json: true
      body:
        data: new_data
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Visualisation
        .findOne(id)
        .exec( (err, visualisation) ->
          assert.equal visualisation.data, new_data
          done()
      )
    )
  )
)
