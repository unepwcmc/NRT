assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

suite('API - Visualisation')

Visualisation = require('../../models/visualisation').model

test('POST create', (done) ->
  data =
    data: "new visualisation"

  request.post({
    url: helpers.appurl('api/visualisations/')
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


test("GET show", (done) ->
  createVisualisation( (visualisation) ->
    request.get({
      url: helpers.appurl("api/visualisations/#{visualisation.id}")
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

test('GET index', (done) ->
  createVisualisation( (visualisation) ->
    request.get({
      url: helpers.appurl("api/visualisations")
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

test('DELETE visualisation', (done) ->
  createVisualisation( (visualisation) ->
    request.del({
      url: helpers.appurl("api/visualisations/#{visualisation.id}")
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

test('PUT visualisation', (done) ->
  createVisualisation( (visualisation) ->
    new_data = "Updated data"
    request.put({
      url: helpers.appurl("/api/visualisations/#{visualisation.id}")
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
