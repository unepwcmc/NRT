assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
Q = require 'q'
async = require('async')
sinon = require('sinon')

suite('API - Indicator')

Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
Page = require('../../models/page').model

test('POST create', (done) ->
  data =
    name: "new indicator"

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
        assert.equal indicator.name, data.name
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

test("GET /indicators/:id/fat returns the indicator with its nested page ", (done) ->
  indicator = null
  nestedPage = new Page()
  toObjectWithNestedPageStub = sinon.stub(Indicator::, 'toObjectWithNestedPage', ->
    Q.fcall(=>
      object = @toObject()
      object.page = nestedPage
      object
    )
  )

  Q.nfcall(
    helpers.createIndicator
  ).then( (createdIndicator) ->
    indicator = createdIndicator

    Q.nfcall(
      request.get, {
        url: helpers.appurl("api/indicators/#{indicator._id}/fat")
        json: true
      }
    )
  ).spread( (res, body) ->

    try
      assert.equal res.statusCode, 200,
        "Expected the query to succeed"

      assert.match res.headers['content-type'], /.*json.*/,
        "Expected the response to be JSON"

      reloadedIndicator = body
      assert.equal reloadedIndicator._id, indicator.id,
        "Expected the query to return the correct indicator"

      assert.property reloadedIndicator, 'page',
        "Expected the page attribute to be populated"

      assert.ok toObjectWithNestedPageStub.calledOnce,
        "Expected indicator.toObjectWithNestedPage to be called"

      assert.equal reloadedIndicator.page._id, nestedPage.id,
        "Expected the page attribute to be the right page"

      done()
    catch err
      done(err)
    finally
      toObjectWithNestedPageStub.restore()

  ).catch( (err) ->
    toObjectWithNestedPageStub.restore()
    done(err)
  )
)

test('GET /api/indicators/ returns all indicators', (done) ->
  async.series([helpers.createIndicator, helpers.createIndicator], (err, indicators) ->
    request.get({
      url: helpers.appurl("api/indicators")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      indicatorJson = body

      assert.equal indicatorJson.length, indicators.length
      jsonNames = _.map(indicatorJson, (indicator)->
        indicator.name
      )
      indicatorNames = _.map(indicators, (indicator)->
        indicator.name
      )

      assert.deepEqual jsonNames, indicatorNames
      done()
    )
  )
)

test('GET /api/indicators?withData=true only returns indicators with indicator data associated', (done) ->
  async.parallel([helpers.createIndicator, helpers.createIndicator], (err, indicators) ->
    indicatorWithData = indicators[0]

    helpers.createIndicatorData(
      indicator: indicatorWithData._id
    ).then( ->

      request.get({
        url: helpers.appurl("api/indicators")
        qs: withData: true
        json: true
      }, (err, res, body) ->
        assert.equal res.statusCode, 200

        indicatorJson = body

        try
          assert.lengthOf indicatorJson, 1, "Only the indicator with data is expected"

          assert.strictEqual indicatorJson[0]._id, indicatorWithData._id.toString(),
            "Expected the indicator with data to be returned"
          done()
        catch err
          done(err)
      )

    ).catch(done)
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
    newName = "Updated name"
    request.put({
      url: helpers.appurl("/api/indicators/#{indicator.id}")
      json: true
      body:
        name: newName
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Indicator
        .findOne(id)
        .exec( (err, indicator) ->
          assert.equal indicator.name, newName

          done()
        )
    )
  )
)

test('PUT indicator does not fail when an _id is given', (done) ->
  helpers.createIndicator( (err, indicator) ->
    newName = "Updated name"
    request.put({
      url: helpers.appurl("/api/indicators/#{indicator.id}")
      json: true
      body:
        _id: indicator.id
        name: newName
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Indicator
        .findOne(id)
        .exec( (err, indicator) ->
          assert.equal indicator.name, newName
          done()
        )
    )
  )
)

test('PUT indicator does not fail when Theme is given as an object', (done) ->
  theme = new Theme(
    title: 'Themes themes themes'
  )

  Q.nfcall(
    helpers.createIndicator, {}
  ).then( (indicator) ->
    Q.nfcall(
      request.put, {
        url: helpers.appurl("/api/indicators/#{indicator.id}")
        json: true
        body:
          theme: theme.toObject()
      }
    )
  ).spread( (res, body) ->
    assert.equal res.statusCode, 200

    done()
  ).catch( (err) ->
    console.error err
    console.error err.stack
    done(err)
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

    helpers.createIndicatorData({
      data: theData
      indicator: theIndicator
    })
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

  ).catch( (err) ->
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

    helpers.createIndicatorData({
      data: theData
      indicator: theIndicator
    })
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
  ).catch( (err) ->
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
  csvData = [
    ["year, yeah?", "value"],
    ["2000", "3"],
    ["2001", "4"],
    ["2002", "4"]
  ]

  expectedCSVData = """
    "year, yeah?",value\n2000,3\n2001,4\n2002,4
  """

  getIndicatorDataStub = sinon.stub(Indicator::, 'getIndicatorDataForCSV',
    (filters, callback) ->
      callback(null, csvData)
  )

  metadata = [
    ['meta']
    ['data']
  ]

  expectedMetadata = """
    meta\ndata
  """

  generateMetadataCSVStub = sinon.stub(Indicator::, 'generateMetadataCSV', ->
    Q.fcall(-> metadata)
  )

  restoreStubs = ->
    getIndicatorDataStub.restore()
    generateMetadataCSVStub.restore()

  theIndicator = null

  helpers.createIndicatorModels([
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
  ]).then( (indicators) ->
    theIndicator = indicators[0]

    request.get({
      url: helpers.appurl("/api/indicators/#{theIndicator.id}/data.csv")
      encoding: null
    }, (err, res, body) ->
      if err?
        restoreStubs()
        return done(err)

      try
        assert.equal res.statusCode, 200

        require('node-zip')()

        zipFile = new JSZip()
        zipFile.load(body.toString("base64"), base64:true)

        csvFile = zipFile.file('data.csv')

        assert.strictEqual(
          csvFile.asText(),
          expectedCSVData,
          "Expected \n#{csvFile.name} \nto contain \n #{expectedCSVData}"
        )

        csvFile = zipFile.file('metadata.csv')

        assert.isNotNull csvFile, "Expected the metadata to be in the zip file"

        assert.strictEqual(
          csvFile.asText(),
          expectedMetadata,
          "Expected \n#{csvFile.name} \nto contain \n #{expectedCSVData}"
        )

        done()
      catch e
        done(e)
      finally
        restoreStubs()
    )

  ).catch( (err) ->
    console.error err
    restoreStubs()
    done(err)
  )
)

test('GET /:id/headlines returns the 5 most recent headlines in descending order', (done) ->
  indicatorData = [
    {
      "year": 2000,
      "value": 2
      "text": 'Poor'
    }, {
      "year": 2001,
      "value": 9
      "text": 'Great'
    }, {
      "year": 2002,
      "value": 4
      "text": 'Fair'
    }, {
      "year": 2004,
      "value": 4
      "text": 'Fair'
    }, {
      "year": 2003,
      "value": 4
      "text": 'Fair'
    }
  ]

  indicatorDefinition =
    xAxis: 'year'
    yAxis: 'value'
    textField: 'text'
    fields: [{
      name: 'year'
      type: 'integer'
    }, {
      name: "value",
      type: "integer"
    }, {
      name: 'text'
      name: 'text'
    }]

  theIndicator = null

  Q.nsend(
    Indicator, 'create',
      indicatorDefinition: indicatorDefinition
  ).then( (indicator) ->
    theIndicator = indicator

    Q.nsend(
      IndicatorData, 'create'
        indicator: theIndicator
        data: indicatorData
    )
  ).then( ->
    Q.nfcall(
      request.get, {
        url: helpers.appurl("api/indicators/#{theIndicator.id}/headlines")
      }
    )
  ).spread( (res, body) ->
    try
      headlines = JSON.parse(body)

      assert.equal res.statusCode, 200

      assert.lengthOf headlines, 5, "Expected 5 headlines to be returned"

      mostRecentHeadline = headlines[0]
      assert.strictEqual mostRecentHeadline.year, 2004, "Expected the most recent headline first"

      done()
    catch e
      done(e)

  ).catch((err) ->
    console.error err
    throw err
  )
)

test('GET /:id/headlines/:number returns the n most recent headlines', (done) ->
  indicatorData = [
    {
      "year": 2000,
      "value": 2
      "text": 'Poor'
    }, {
      "year": 2001,
      "value": 9
      "text": 'Great'
    }, {
      "year": 2002,
      "value": 4
      "text": 'Fair'
    }, {
      "year": 2003,
      "value": 4
      "text": 'Fair'
    }, {
      "year": 2004,
      "value": 4
      "text": 'Fair'
    }
  ]

  indicatorDefinition =
    xAxis: 'year'
    yAxis: 'value'
    textField: 'text'
    fields: [{
      name: 'year'
      type: 'integer'
    }, {
      name: "value",
      type: "integer"
    }, {
      name: 'text'
      name: 'text'
    }]

  theIndicator = null

  Q.nsend(
    Indicator, 'create',
      indicatorDefinition: indicatorDefinition
  ).then( (indicator) ->
    theIndicator = indicator

    Q.nsend(
      IndicatorData, 'create'
        indicator: theIndicator
        data: indicatorData
    )
  ).then( ->
    Q.nfcall(
      request.get, {
        url: helpers.appurl("api/indicators/#{theIndicator.id}/headlines/3")
      }
    )
  ).spread( (res, body) ->
    try
      headlines = JSON.parse(body)

      assert.equal res.statusCode, 200

      assert.lengthOf headlines, 3, "Expected 3 headlines to be returned"

      done()
    catch e
      done(e)

  ).catch((err) ->
    console.error err
    throw err
  )
)
