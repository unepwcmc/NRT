assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
Q = require 'q'
async = require('async')

suite('API - Indicator')

Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model

test('POST create', (done) ->
  data =
    title: "new indicator"

  request.post({
    url: helpers.appurl('api/indicators/')
    json: true
    body: data
  },(err, res, body) ->
    id = body._id

    assert.equal res.statusCode, 201

    Indicator
      .findOne(_id: id)
      .exec( (err, indicator) ->
        assert.equal indicator.title, data.title
        done()
      )
  )
)

test("GET show", (done) ->
  helpers.createIndicator( (err, indicator) ->
    request.get({
      url: helpers.appurl("api/indicators/#{indicator.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedIndicator = body
      assert.equal reloadedIndicator._id, indicator.id
      assert.equal reloadedIndicator.content, indicator.content

      done()
    )
  )
)

test('GET index', (done) ->
  async.series([helpers.createIndicator, helpers.createIndicator], (err, indicators) ->
    request.get({
      url: helpers.appurl("api/indicators")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      indicatorJson = body

      assert.equal indicatorJson.length, indicators.length
      jsonTitles = _.map(indicatorJson, (indicator)->
        indicator.title
      )
      indicatorTitles = _.map(indicators, (indicator)->
        indicator.title
      )

      assert.deepEqual jsonTitles, indicatorTitles
      done()
    )
  )
)

test('DELETE indicator', (done) ->
  helpers.createIndicator( (err, indicator) ->
    request.del({
      url: helpers.appurl("api/indicators/#{indicator.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204

      Indicator.count( (err, count)->
        unless err?
          assert.equal 0, count
          done()
      )
    )
  )
)

test('PUT indicator', (done) ->
  helpers.createIndicator( (err, indicator) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/indicators/#{indicator.id}")
      json: true
      body:
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Indicator
        .findOne(id)
        .exec( (err, indicator) ->
          assert.equal indicator.title, new_title

          done()
        )
    )
  )
)

test('PUT indicator does not fail when an _id is given', (done) ->
  helpers.createIndicator( (err, indicator) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/indicators/#{indicator.id}")
      json: true
      body:
        _id: indicator.id
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Indicator
        .findOne(id)
        .exec( (err, indicator) ->
          assert.equal indicator.title, new_title
          done()
        )
    )
  )
)

test('GET indicator/:id/data returns the indicator data and bounds as JSON', (done) ->
  theData = [{
    year: 2000
    value: 4
  }]
  theIndicator = null

  helpers.createIndicatorModels([
    indicatorDefinition: {
      fields: [{
        name: 'year'
        type: 'integer'
      },{
        name: 'value'
        type: 'integer'
      }]
    }
  ]).then( (indicators) ->
    theIndicator = indicators[0]

    Q.nfcall(
      helpers.createIndicatorData, {
        data: theData
        indicator: theIndicator
      }
    )
  ).then( ->

    request.get({
      url: helpers.appurl("/api/indicators/#{theIndicator.id}/data")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.match(res.headers['content-type'], new RegExp('json'))

      assert.property(body, 'results')
      assert.ok(_.isEqual body.results, theData)
      assert.property(body, 'bounds')

      done()
    )

  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('GET indicator/:id/data with a \'min\' filter filters the result', (done) ->
  theData = [{
    year: 2000
    value: 4
  },{
    year: 2002
    value: 50
  }]

  theIndicator = null

  helpers.createIndicatorModels([
    indicatorDefinition: {
      fields: [{
        name: 'year'
        type: 'integer'
      },{
        name: 'value'
        type: 'integer'
      }]
    }
  ]).then( (indicators) ->
    theIndicator = indicators[0]

    Q.nfcall(
      helpers.createIndicatorData, {
        data: theData
        indicator: theIndicator
      }
    )
  ).then( ->
    request.get({
      url: helpers.appurl("/api/indicators/#{theIndicator.id}/data?filters[value][min]=5")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      # Assert only the value about 40 is returned
      assert.ok(_.isEqual(
        body.results,
        [theData[1]]
      ), "Expected \n#{body.results} \nto equal \n#{[theData[1]]}")
      assert.property(body, 'bounds')

      done()
    )
  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('GET indicator/:id returns the indicator data', (done) ->
  helpers.createIndicator({}, (err, indicator) ->
    request.get({
      url: helpers.appurl("api/indicators/#{indicator.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      returnedIndicator = body
      assert.equal returnedIndicator._id, indicator.id
      assert.equal returnedIndicator.content, indicator.content

      done()
    )
  )
)

test('GET indicator/:id/data.csv returns the indicator data as a CSV', (done) ->
  data = [
    {
      "year": 2000,
      "value": 3
    }, {
      "year": 2001,
      "value": 4
    }, {
      "year": 2002,
      "value": 4
    }
  ]

  expectedData = """
    "year","value"\r\n"2000","3"\r\n"2001","4"\r\n"2002","4"\r\n
  """

  theIndicator = null

  helpers.createIndicatorModels([
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
  ]).then( (indicators) ->
    theIndicator = indicators[0]

    Q.nfcall(
      helpers.createIndicatorData, {
        data: data
        indicator: theIndicator
      }
    )
  ).then( ->

    request.get({
      url: helpers.appurl("/api/indicators/#{theIndicator.id}/data.csv")
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.strictEqual(
         body,
         expectedData,
         "Expected \n#{body} \nto equal \n #{expectedData}"
      )

      done()
    )
    
  ).fail( (err) ->
    console.error err
    throw err
  )

)
