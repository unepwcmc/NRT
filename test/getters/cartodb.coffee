assert = require('chai').assert
sinon = require('sinon')
Q = require('q')
_ = require('underscore')
request = require('request')

Indicator = require('../../models/indicator')
CartoDBGetter = require("../../getters/cartodb")

suite('CartoDB getter')

test("CartoDBGetter stores a reference to the given indicator", ->
  indicator = {some: "data"}

  getter = new CartoDBGetter(
    indicator
  )

  assert.strictEqual(getter.indicator, indicator)
)

test(".fetch builds a request URL, queries it, and returns the data", (done) ->
  getter = new CartoDBGetter({})

  fakeCartodbURL = "http://fake.cartodb/api"
  sinon.stub(getter, 'buildUrl', ->
    return fakeCartodbURL
  )

  theData =
    rows: {some: 'data'}
  getStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, body: theData)
  )

  getter.fetch().then((fetchedData)->
    try
      assert.isTrue(
        getStub.calledWith({url: fakeCartodbURL}),
        "Expected request.get to be called with the result of @buildUrl,
        but called with #{getStub.getCall(0).args}"
      )

      assert.strictEqual(fetchedData, theData.rows,
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

test('.buildUrl throws an error if the Indicator does not have any CartoDB configs', ->
  indicator = new Indicator()
  getter = new CartoDBGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator does not define a cartodb_config attribute")
)

test('.buildUrl throws an error if the Indicator cartodb_config does not specify a username', ->
  indicator = new Indicator(
    cartodb_config: {}
  )
  getter = new CartoDBGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator cartodb_config does not define a username attribute")
)

test('.buildUrl throws an error if the Indicator cartodb_config does not specify a query', ->
  indicator = new Indicator(
    cartodb_config:
      username: ''
  )
  getter = new CartoDBGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator cartodb_config does not define a query attribute")
)

test('.buildUrl constructs the correct URL with username and query', ->
  indicator = new Indicator(
    cartodb_config:
      username: 'someguy'
      query: 'select * the things'
  )

  getter = new CartoDBGetter(indicator)

  builtUrl = getter.buildUrl()
  expectedUrl = "http://someguy.cartodb.com/api/v2/sql?q=select * the things"

  assert.strictEqual builtUrl, expectedUrl
)
