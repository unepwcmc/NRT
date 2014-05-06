assert = require('chai').assert
sinon = require('sinon')
request = require('request')

Indicator = require('../../../../models/indicator').model
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
    rows: [
      {header: 'row'},
      {indicator: 'row'}
    ]
  getStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, body: JSON.stringify(theData))
  )

  getter.fetch().then((fetchedData)->
    try
      assert.isTrue(
        getStub.calledWith({url: fakeCartodbURL}),
        "Expected request.get to be called with the result of @buildUrl,
        but called with #{getStub.getCall(0).args}"
      )

      assert.deepEqual(fetchedData, theData.rows,
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

test(".fetch if only the header row is returned, throw a 'can't find indicator' error", (done)->
  indicator = {name: 'an indicator'}
  getter = new CartoDBGetter(indicator)

  fakeCartodbURL = "http://fake.cartodb/api"
  sinon.stub(getter, 'buildUrl', ->
    return fakeCartodbURL
  )

  theData =
    rows: [header: 'row']
  getStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, body: JSON.stringify(theData))
  )

  getter.fetch().then((fetchedData)->
    getStub.restore()
    done(new Error("Expected CartoDBGetter.fetch to fail, but it succeeded"))

  ).fail((err) ->

    try
      assert.strictEqual(
        err.message, "Unable to find indicator with name '#{indicator.name}'",
        "Expected the error to have the right message"
      )
      done()

    catch err
      done(err)
    finally
      getStub.restore()
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
    indicatorationConfig:
      cartodb_config: {}
  )
  getter = new CartoDBGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator cartodb_config does not define a username attribute")
)

test('.buildUrl throws an error if the Indicator cartodb_config does not specify a table_name', ->
  indicator = new Indicator(
    indicatorationConfig:
      cartodb_config:
        username: ''
  )
  getter = new CartoDBGetter(indicator)

  assert.throw( (->
    getter.buildUrl()
  ), "Indicator cartodb_config does not define a table_name attribute")
)

test('.buildUrl constructs the correct URL with username and query', ->
  indicator = new Indicator(
    short_name: "CO 2"
    indicatorationConfig:
      cartodb_config:
        username: 'someguy'
        table_name: 'dat_table'
  )

  getter = new CartoDBGetter(indicator)

  builtUrl = getter.buildUrl()
  expectedUrl = "http://someguy.cartodb.com/api/v2/sql?q=SELECT * FROM dat_table\nWHERE field_2 = 'CO 2'\nOR field_1 = 'Theme'"

  assert.strictEqual builtUrl, expectedUrl
)
