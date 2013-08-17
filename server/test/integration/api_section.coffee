assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
_ = require('underscore')

suite('API - Section')

Section = require('../../models/section').model

test('posting creates a section', (done) ->
  data =
    title: "test section title 1"
    report_id: 5

  request.post {
    url: helpers.appurl('/api/section')
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

createReport = (callback) ->
  Report = require('../../models/report').model
  report = new Report(
    title: "new report"
  )

  report.save (err, report) ->
    if err?
      throw 'could not save report'

    callback(null, report)

test('POST section with report id nests section in report')

test('POST section with nested indicator', (done) ->
  Indicator = require('../../models/indicator').model

  createIndicator = (callback) ->
    indicator = new Indicator(
      title: "new indicator"
    )

    indicator.save (err, indicator) ->
      if err?
        throw 'could not save indicator'

      callback(indicator)

  createSectionWithIndicator = (indicator) ->
    indicator_id = indicator._id

    data =
      title: "test section title 1"
      indicator: indicator_id

    request.post {
      url: helpers.appurl('/api/section')
      json: true
      body: data
    }, (err, res, body) ->
      id = body._id
      assert.equal res.statusCode, 201

      assert.property body, 'indicator'
      assert.equal indicator_id, body.indicator._id

      done()

  createIndicator(createSectionWithIndicator)
)

test('POST section with nested narrative', (done) ->
  Narrative = require('../../models/narrative').model

  createNarrative = (callback) ->
    narrative = new Narrative(
      content: "new narrative"
    )

    narrative.save (err, narrative) ->
      if err?
        throw 'could not save narrative'

      callback(narrative)

  createSectionWithNarrative = (narrative) ->
    narrative_id = narrative._id

    data =
      title: "test section title 1"
      narrative: narrative_id

    request.post {
      url: helpers.appurl('/api/section')
      json: true
      body: data
    }, (err, res, body) ->
      id = body._id
      assert.equal res.statusCode, 201

      assert.property body, 'narrative'
      assert.equal narrative_id, body.narrative._id

      done()

  createNarrative(createSectionWithNarrative)
)

test('POST section with nested visualisation', (done) ->
  visualisation = require('../../models/visualisation').model

  createVisualisation = (callback) ->
    visualisation = new visualisation(
      data: "new visualisation"
    )

    visualisation.save (err, visualisation) ->
      if err?
        throw 'could not save visualisation'

      callback(visualisation)

  createSectionWithVisualisation = (visualisation) ->
    visualisation_id = visualisation._id

    data =
      title: "test section title 1"
      visualisation: visualisation_id

    request.post {
      url: helpers.appurl('/api/section')
      json: true
      body: data
    }, (err, res, body) ->
      id = body._id
      assert.equal res.statusCode, 201

      assert.property body, 'visualisation'
      assert.equal visualisation_id, body.visualisation._id

      done()

  createVisualisation(createSectionWithVisualisation)
)

createSection = (callback) ->
  section = new Section(content: "a section")

  section.save (err, section) ->
    if err?
      throw 'could not save section'

    callback(section)

test('update section with new indicator')
test('update section with new narrative')
test('update section with new visualisation')

test('can update a section', (done) ->
  createSection( (section) ->
    newTitle = 'new title'

    request.put {
      url: helpers.appurl("api/section/#{section.id}")
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

test("show returns a section's data", (done) ->
  createSection( (section) ->
    request.get({
      url: helpers.appurl("api/section/#{section.id}")
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

test("show returns a section's nested models")

test('can destroy a section', (done) ->
  createSection( (section) ->
    request.del({
      url: helpers.appurl("api/section/#{section.id}")
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

test('index lists all sections', (done) ->
  createSection( (section) ->
    request.get({
      url: helpers.appurl("api/section")
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
