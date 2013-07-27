assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

suite('API - Narrative')

test('create', (done) ->
  data =
    content: "new narrative"
    section_id: 5

  Narrative = require('../../models/narrative')
  request.post({
    url: helpers.appurl('api/narrative/')
    json: true
    body: data
  },(err, res, body) ->
    id = body.id

    assert.equal res.statusCode, 201

    Narrative.find(id).success((narrative) ->
      assert.equal narrative.content, data.content
      assert.equal narrative.section_id, data.section_id
      done()
    )
  )
)
