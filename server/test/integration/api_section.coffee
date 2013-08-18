assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
_ = require('underscore')

suite('API - Section')

Indicator = require('../../models/indicator').model
Visualisation = require('../../models/visualisation').model
Narrative = require('../../models/narrative').model
Section = require('../../models/section').model

test('POST create', (done) ->
  data =
    title: "test section title 1"

  request.post {
    url: helpers.appurl('/api/sections')
    json: true
    body: data
  }, (err, res, body) ->
    id = body._id
    assert.equal res.statusCode, 201

    section = body
    assert.equal section._id, id
    assert.equal section.title, data.title

    # TODO test to see if added to report

    done()
)

test('POST section with nested indicator', (done) ->
  createSectionWithIndicator = (err, indicator) ->
    indicator_id = indicator._id

    data =
      title: "test section title 1"
      indicator: indicator_id

    request.post {
      url: helpers.appurl('/api/sections')
      json: true
      body: data
    }, (err, res, body) ->
      id = body._id
      assert.equal res.statusCode, 201

      assert.property body, 'indicator'
      assert.equal indicator_id, body.indicator._id

      done()

  helpers.createIndicator(createSectionWithIndicator)
)

test('POST section with nested narrative', (done) ->
  createSectionWithNarrative = (err, narrative) ->
    narrative_id = narrative._id

    data =
      title: "test section title 1"
      narrative: narrative_id

    request.post {
      url: helpers.appurl('/api/sections')
      json: true
      body: data
    }, (err, res, body) ->
      id = body._id
      assert.equal res.statusCode, 201

      assert.property body, 'narrative'
      assert.equal narrative_id, body.narrative._id

      done()

  helpers.createNarrative(createSectionWithNarrative)
)

test('POST section with nested visualisation', (done) ->
  createSectionWithVisualisation = (err, visualisation) ->
    visualisation_id = visualisation._id

    data =
      title: "test section title 1"
      visualisation: visualisation_id

    request.post {
      url: helpers.appurl('/api/sections')
      json: true
      body: data
    }, (err, res, body) ->
      id = body._id
      assert.equal res.statusCode, 201

      assert.property body, 'visualisation'
      assert.equal visualisation_id, body.visualisation._id

      done()

  helpers.createVisualisation(createSectionWithVisualisation)
)

test('PUT section with new indicator', (done) ->
  createSectionWithIndicator = (err, results) ->
    indicator = results[0]
    newIndicator = results[1]

    helpers.createSection(
      {title: 'A section', indicator: indicator._id},
      (err, section) ->
        request.put {
          url: helpers.appurl("api/sections/#{section.id}")
          json: true
          body:
            indicator: newIndicator._id
        }, (err, res, body) ->
          assert.equal res.statusCode, 200
          assert.property body, 'indicator'

          assert.equal "A section", body.title

          done()
    )

  async.series([helpers.createIndicator, helpers.createIndicator], createSectionWithIndicator)
)

test('create when given no title or indicator should return an appropriate erro', (done)->
  request.post {
    url: helpers.appurl('/api/sections')
    json: true
    body: {}
  }, (err, res, body) ->
    assert.equal res.statusCode, 422

    assert.match res.body, /.*title or indicator must be present.*/
    done()
)

test('PUT section', (done) ->
  helpers.createSection( (err, section) ->
    newTitle = 'new title'

    request.put {
      url: helpers.appurl("api/sections/#{section.id}")
      json: true
      body:
        title: newTitle
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      Section
        .findOne(section.id)
        .exec( (err, reloadedSection)->
          if err?
            console.error error
            throw "Unable to recall updated section"

          assert.equal reloadedSection.title, newTitle
          done()
        )
  )
)

test('PUT section does not fail when given an _id', (done) ->
  helpers.createSection( (err, section) ->
    newTitle = 'new title'

    request.put {
      url: helpers.appurl("api/sections/#{section.id}")
      json: true
      body:
        _id: section.id
        title: newTitle
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      Section
        .findOne(section.id)
        .exec( (err, reloadedSection)->
          if err?
            console.error error
            throw "Unable to recall updated section"

          assert.equal reloadedSection.title, newTitle
          done()
        )
  )
)


test("show returns a section's data", (done) ->
  helpers.createSection( (err, section) ->
    request.get({
      url: helpers.appurl("api/sections/#{section.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedSection = body
      assert.equal reloadedSection._id, section.id
      assert.equal reloadedSection.content, section.content

      done()
    )
  )
)

test("GET /section/<id> returns a section's nested models", (done) ->
  createSectionWithSubDocuments = (err, results) ->
    indicator = results[0]
    visualisation = results[1]
    narrative = results[2]

    helpers.createSection(
      {
        title: 'A section',
        indicator: indicator._id
        visualisation: visualisation._id
        narrative: narrative._id
      },
      (err, section) ->
        request.get({
          url: helpers.appurl("api/sections/#{section.id}")
          json: true
        }, (err, res, body) ->
          assert.equal res.statusCode, 200

          reloadedSection = body
          assert.equal reloadedSection._id, section.id

          assert.property body, 'indicator'
          assert.equal indicator._id, body.indicator._id

          assert.property body, 'visualisation'
          assert.equal visualisation._id, body.visualisation._id

          assert.property body, 'narrative'
          assert.equal narrative._id, body.narrative._id

          done()
        )
    )

  async.series([
    helpers.createIndicator,
    helpers.createVisualisation,
    helpers.createNarrative
  ], createSectionWithSubDocuments)
)

test('DELETE section', (done) ->
  helpers.createSection( (err, section) ->
    request.del({
      url: helpers.appurl("api/sections/#{section.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204

      Section.count( (err, count)->
        unless err?
          assert.equal 0, count
          done()
      )
    )
  )
)

test('GET index', (done) ->
  helpers.createSection( (err, section) ->
    request.get({
      url: helpers.appurl("api/sections")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      sections = body
      assert.equal 1, sections.length
      assert.equal sections[0]._id, section.id
      assert.equal sections[0].content, section.content

      done()
    )
  )
)
