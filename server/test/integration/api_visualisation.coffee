assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

suite('API - Visualisation')

test('create', (done) ->
  data =
    data: "new visualisation"
    section_id: 5

  Visualisation = require('../../models/visualisation')
  request.post({
    url: helpers.appurl('api/visualisation/')
    json: true
    body: data
  },(err, res, body) ->
    id = body.id

    assert.equal res.statusCode, 201

    Visualisation.find(id).success((visualisation) ->
      assert.equal visualisation.data, data.data
      assert.equal visualisation.section_id, data.section_id
      done()
    )
  )
)
