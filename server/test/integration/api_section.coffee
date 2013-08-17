assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
_ = require('underscore')


suite('API - Section')
test('create, read', (done) ->
  data =
    title: "test section title 1"
    report_id: 5
    narratives: []
    visualisations: []

  request.post {
    url: helpers.appurl('/api/section')
    json: true
    body: data
  }, (err, res, body) ->
    id = body.id
    assert.equal res.statusCode, 201

    request.get {
      url: helpers.appurl('/api/section/' + id)
      json: true
    }, (err, res, body) ->
      section = body
      assert.equal section.id, id
      assert.equal section.title, data.title
      assert.equal section.report_id, data.report_id
      assert.equal res.statusCode, 200
      done()
)

test('create when given no title or indicator should return an appropriate erro', (done)->
  request.post {
    url: helpers.appurl('/api/section')
    json: true
    body: {}
  }, (err, res, body) ->
    assert.equal res.statusCode, 422

    assert.match res.body, /.*title or indicator must be present.*/
    done()
)

test('update', (done) ->
  Section = require('../../models/section')

  Section.create(title: 'old title').success((section)->
    newTitle = 'new title'

    request.put {
      url: helpers.appurl("api/section/#{section.id}")
      json: true
      body:
        title: newTitle
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      Section.find(section.id).success((reloadedSection)->
        assert.equal reloadedSection.title, newTitle
        done()
      ).error((error) ->
        console.error error
        throw "Unable to recall updated section"
      )
  ).error((error) ->
    console.error error
    throw "unable to create section"
  )
)

test('list', (done) ->
  data =
    title: "test section title 2"
    report_id: 5
    narratives: []
    visualisations: []

  opts =
    url: helpers.appurl('/api/section')
    json: true
    body: data

  async.parallel({
    section1: (cb) -> request.post opts, cb
    section2: (cb) -> request.post opts, cb
  }, (err, results) ->

    res1 = results.section1[0]
    res2 = results.section2[0]
    body1 = results.section1[1]
    body2 = results.section2[1]

    assert.equal res1.statusCode, 201
    assert.equal res2.statusCode, 201

    request.get {
      url: helpers.appurl('/api/section')
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200
      assert.equal body.length, 2
      assert.equal body[0].id, body1.id
      assert.equal body[1].id, body2.id
      done()
  )
)
