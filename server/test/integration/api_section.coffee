assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
_ = require('underscore')


appurl = (path) ->
  url.resolve('http://localhost:3001', path)


suite('API - Section')
test('create, read', (done) ->
  data =
    title: "test section title"
    report_id: 5
    narratives: []
    visualisations: []

  request.post {
    url: appurl('/api/section')
    json: true
    body: data
  }, (err, res, body) ->
    id = body.section.id
    assert.equal res.statusCode, 201

    request.get {
      url: appurl('/api/section/' + id)
      json: true
    }, (err, res, body) ->
      section = body.section
      assert.equal section.id, id
      assert.equal section.title, data.title
      assert.equal section.report_id, data.report_id
      assert.equal res.statusCode, 200
      done()
)

test('list', (done) ->
  data =
    title: "test section title"
    report_id: 5
    narratives: []
    visualisations: []

  opts =
    url: appurl('/api/section')
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
      url: appurl('/api/section')
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200
      assert.equal body.length, 2
      assert.equal body[0].id, body1.section.id
      assert.equal body[1].id, body2.section.id
      done()
  )
)
