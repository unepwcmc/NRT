assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')


suite('API - Section')
test('create, read', (done) ->
  data =
    title: "test report title"
    report_id: 5
    narratives: []
    visualisations: []

  _url = (path) ->
    url.resolve('http://localhost:3001', path)

  request.post
    url: _url('/api/section')
    json: true
    body: data,
    (err, res, body) ->
      id = body.section.id
      assert.equal res.statusCode, 201

      request.get
        url: _url('/api/section/' + id)
        json: true,
        (err, res, body) ->
          section = body.section
          assert.equal section.id, id
          assert.equal section.title, data.title
          assert.equal section.report_id, data.report_id
          assert.equal res.statusCode, 200
          done()
)
