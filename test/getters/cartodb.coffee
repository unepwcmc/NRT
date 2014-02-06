assert = require('chai').assert
sinon = require('sinon')
Q = require('q')
_ = require('underscore')

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

  theData = {some: 'data'}
  getStub = sinon.stub(request, 'get', (cb) ->
    cb(null, theData)
  )
  
  getter.fetch().then((fetchedData)->
    try
      assert.isTrue(
        getStub.calledWith(fakeCartodbURL),
        "Expected request.get to be called with the result of @buildUrl,
        but called with #{getStub.getCall(0).args}"
      )

      assert.strictEqual(fetchedData, theData,
        "Expected fetch to return the results of the get request"
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
