assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')

suite('API - Narrative')

test('POST create', (done) ->
  data =
    content: "new narrative"
    section: "235235235235"

  Narrative = require('../../models/narrative').model
  request.post({
    url: helpers.appurl('api/narratives/')
    json: true
    body: data
  },(err, res, body) ->
    id = body._id

    assert.equal res.statusCode, 201

    Narrative
      .findOne(id)
      .exec( (err, narrative) ->
        assert.equal narrative.content, data.content
        assert.equal narrative.section, data.section

        done()
      )
  )
)

test('PUT narrative', (done) ->
  Narrative = require('../../models/narrative').model

  narrative = new Narrative(
    content: "a narrative"
  )

  narrative.save (err, narrative) ->
    if err?
      throw new Error("Could not save narrative")

    newAttributes =
      content: "this is the new content"
      section: "554334224443"

    request.put({
      url: helpers.appurl("api/narratives/#{narrative.id}")
      json: true
      body: newAttributes
    },(err, res, body) ->
      assert.equal res.statusCode, 200

      Narrative
        .findOne(narrative._id)
        .exec( (err, reloadedNarrative) ->
          assert.equal reloadedNarrative.content, newAttributes.content
          assert.equal reloadedNarrative.section, newAttributes.section
          done()
        )
    )
)

test('PUT narrative does not fail when _id given', (done) ->
  Narrative = require('../../models/narrative').model

  narrative = new Narrative(content: "a narrative")

  narrative.save (err, narrative) ->
    if err?
      throw new Error("Could not save narrative")

    newAttributes =
      content: "this is the new content"
      _id: narrative.id

    request.put({
      url: helpers.appurl("api/narratives/#{narrative.id}")
      json: true
      body: newAttributes
    },(err, res, body) ->
      assert.equal res.statusCode, 200

      Narrative
        .findOne(narrative._id)
        .exec( (err, reloadedNarrative) ->
          assert.equal reloadedNarrative.content, newAttributes.content
          assert.equal reloadedNarrative.section_id, newAttributes.section_id
          done()
        )
    )
)

test('GET index', (done) ->
  Narrative = require('../../models/narrative').model

  narrative = new Narrative(
    content: "a narrative"
  )

  narrative.save (err, narrative) ->
    if err?
      throw new Error("Could not save narrative")

    request.get({
      url: helpers.appurl("api/narratives")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      narratives = body
      assert.equal narratives[0]._id, narrative.id
      assert.equal narratives[0].content, narrative.content

      done()
    )
)

test('GET show', (done) ->
  Narrative = require('../../models/narrative').model

  narrative = new Narrative(
    content: "a narrative"
  )

  narrative.save (err, narrative) ->
    if err?
      throw new Error("Could not save narrative")

    request.get({
      url: helpers.appurl("api/narratives/#{narrative._id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedNarrative = body
      assert.equal reloadedNarrative._id, narrative.id
      assert.equal reloadedNarrative.content, narrative.content

      done()
    )
)

test('DELETE narrative', (done) ->
  Narrative = require('../../models/narrative').model

  narrative = new Narrative(
    content: "a narrative"
  )

  narrative.save (err, narrative) ->
    if err?
      throw new Error("Could not save narrative")

    request.del({
      url: helpers.appurl("api/narratives/#{narrative.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204
      done()
    )
)
