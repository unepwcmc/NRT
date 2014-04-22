assert = require('chai').assert
sinon = require('sinon')
request = require('request')

Indicator = require('../../models/indicator')
EsriGetter = require("../../getters/esri")

suite('Esri getter')

test('.buildUrl throws an error if the Indicator does not have any Esri configs', ->
  indicator = new Indicator()
  getter = new EsriGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator does not define a esriConfig attribute")
)

test('.buildUrl throws an error if the Indicator esriConfig does not specify a serviceName', ->
  indicator = new Indicator(
    esriConfig: {}
  )
  getter = new EsriGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator esriConfig does not define a serviceName attribute")
)

test('.buildUrl throws an error if the Indicator esriConfig does not specify a featureServer', ->
  indicator = new Indicator(
    esriConfig:
      serviceName: ''
  )
  getter = new EsriGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator esriConfig does not define a featureServer attribute")
)

test('.buildUrl throws an error if the Indicator esriConfig does not specify a serverUrl', ->
  indicator = new Indicator(
    esriConfig:
      serviceName: ''
      featureServer: ''
  )
  getter = new EsriGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator esriConfig does not define a serverUrl attribute")
)

test('.buildUrl constructs the correct URL with serviceName, featureServer, serverUrl', ->
  indicator = new Indicator(
    name: "Phosphate P Diddy"
    esriConfig:
      serverUrl: 'http://esri-server.com/rest/services'
      serviceName: 'WQ'
      featureServer: '4'
  )

  getter = new EsriGetter(indicator)

  builtUrl = getter.buildUrl()
  expectedUrl = "http://esri-server.com/rest/services/WQ/FeatureServer/4/query"

  assert.strictEqual builtUrl, expectedUrl
)

test(".fetch builds a request URL, queries it, and returns the data", (done) ->
  getter = new EsriGetter({})

  fakeEsriURL = "http://fake.esri-server/rest/services"
  sinon.stub(getter, 'buildUrl', ->
    return fakeEsriURL
  )

  theData = {some: 'data', goes: 'in', here: 'ok'}
  getStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, body: JSON.stringify(theData))
  )

  getter.fetch().then((fetchedData)->
    try
      assert.isTrue(
        getStub.calledWith({url: fakeEsriURL, qs: getter.getQueryParams()}),
        "Expected request.get to be called with the result of @buildUrl,
        but called with #{getStub.getCall(0).args}"
      )

      assert.deepEqual(fetchedData, theData,
        "Expected fetch to return the rows of the get request"
      )
      done()

    catch err
      done(err)

    finally
      getStub.restore()
  ).fail((err) ->
    getStub.restore()
    done(err)
  )
)

test(".fetch throws an error if the Esri server returns an error", (done) ->
  getter = new EsriGetter({})

  fakeEsriURL = "http://fake.esri-server/rest/services"
  sinon.stub(getter, 'buildUrl', ->
    return fakeEsriURL
  )

  errorResponse = {
    "error": {
      "code": 400,
      "details": [
        "Invalid Layer or Table ID: 987."
      ],
      "message": "Invalid or missing input parameters."
    }
  }

  getStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, body: JSON.stringify(errorResponse))
  )

  getter.fetch().then(->
    getStub.restore()
    done(new Error("👴👵 Expected fetch not to succeed"))
  ).fail( (errorThrown)->
    try
      assert.deepEqual(errorThrown, errorResponse.error,
        "Expected fetch to return the rows of the get request"
      )
      done()

    catch err
      done(err)

    finally
      getStub.restore()
  )
)
