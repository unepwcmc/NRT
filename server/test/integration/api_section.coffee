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

    done()
)

test('add narrative')
test('add indicator')
test('add visualisation')

test('can update a section', (done) ->
  section = new Section(title: 'old title')
  section.save (err, section)->
    if err?
      throw "Could not create section"

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

test("show returns a section's data", (done) ->
  section = new Section(content: "a section")

  section.save (err, section) ->
    if err?
      throw 'could not save section'

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

test('can destroy a section', (done) ->
  section = new Section(content: "a section")

  section.save (err, section) ->
    if err?
      throw 'could not save section'

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

test('index lists all sections', (done) ->
  section = new Section(content: "a section")

  section.save (err, section) ->
    if err?
      throw 'could not save section'

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
