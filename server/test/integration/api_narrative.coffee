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

test('update', (done) ->
  Narrative = require('../../models/narrative')
  Narrative.create(
    content: "a narrative"
    section_id: 5
  ).success((narrative) ->
    newAttributes =
      content: "this is the new content"
      section_id: 6

    request.put({
      url: helpers.appurl("api/narrative/#{narrative.id}")
      json: true
      body: newAttributes
    },(err, res, body) ->
      assert.equal res.statusCode, 200

      Narrative.find(narrative.id).success((reloadedNarrative) ->
        assert.equal reloadedNarrative.content, newAttributes.content
        assert.equal reloadedNarrative.section_id, newAttributes.section_id
        done()
      )
    )
  )
)
