assert = require('chai').assert
sinon = require('sinon')
request = require('request')

Indicator = require('../../../../../models/indicator').model
WorldBankGetter = require("../../../getters/world_bank")

suite('WorldBank getter')

test('.constructor throws an error if the Indicator does not have any WorldBank configs', ->
  indicator = new Indicator()

  assert.throw( (->
    new WorldBankGetter(indicator)
  ), "Indicator does not define a worldBankConfig attribute")
)

test('.constructor throws an error if the Indicator worldBankConfig does not specify a countryCode', ->
  indicator = new Indicator(
    indicatorationConfig:
      worldBankConfig: {}
  )

  assert.throw( (->
    new WorldBankGetter(indicator)
  ), "Indicator worldBankConfig does not define a countryCode attribute")
)

test('.constructor throws an error if the Indicator worldBankConfig does not specify a serviceName', ->
  indicator = new Indicator(
    indicatorationConfig:
      worldBankConfig:
        countryCode: 'MU'
  )

  assert.throw( (->
    new WorldBankGetter(indicator)
  ), "Indicator worldBankConfig does not define a indicatorCode attribute")
)

test('.buildUrl constructs the correct URL with serviceName, featureServer, serverUrl', ->
  indicator = new Indicator(
    indicatorationConfig:
      worldBankConfig:
        countryCode: 'MU'
        indicatorCode: 'AG.LND.FRST.ZS'
  )

  getter = new WorldBankGetter(indicator)

  builtUrl = getter.buildUrl()
  expectedUrl = "http://api.worldbank.org/countries/MU/indicators/AG.LND.FRST.ZS"

  assert.strictEqual builtUrl, expectedUrl
)

test(".fetch builds a request URL, queries it, and returns the data", (done) ->
  getter = new WorldBankGetter(
    new Indicator(
      indicatorationConfig:
        worldBankConfig:
          countryCode: 'MU'
          indicatorCode: 'AG.LND.FRST.ZS'
    )
  )

  fakeWorldBankURL = "http://test.worldbank.org"
  sinon.stub(getter, 'buildUrl', ->
    return fakeWorldBankURL
  )

  theData = {some: 'data', goes: 'in', here: 'ok'}
  getStub = sinon.stub(request, 'get', (options, cb) ->
    cb(null, body: JSON.stringify(theData))
  )

  getter.fetch().then((fetchedData)->
    try
      assert.strictEqual(getStub.callCount, 1,
        "Expected a request to be sent")

      callArgs = getStub.getCall(0).args

      assert.strictEqual callArgs[0].url, fakeWorldBankURL,
        "Expected request to be sent buildQuery url"

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
