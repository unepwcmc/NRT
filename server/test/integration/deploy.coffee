assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
fs = require('fs')
sinon = require('sinon')
Q = require('q')
Promise = require('bluebird')

CommandRunner = require('../../lib/command_runner')
AppConfig = require('../../initializers/config')
range_check = require('range_check')
Deploy = require('../../lib/deploy')

suite('Deploy')

test('POST /deploy with a github payload for new deploy tag which refers
to the same server-name as the server causes the server to trigger the deploy
command', (done) ->
  sandbox = sinon.sandbox.create()

  deployRole = 'staging'
  tagName = "#{deployRole}-test-webhooks-1bcc7a0470"
  commitHookPayload = {
    "ref": tagName,
    "ref_type": "tag"
  }

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> true)

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'deploy'
      return server_name: deployRole
  )

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->
    new Promise(()->)
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: commitHookPayload
    }
  ).spread( (res, body) ->

    try
      assert.equal res.statusCode, 200,
        "Expected the request to succeed"

      assert.strictEqual updateCodeStub.callCount, 1,
        "Expected Deploy.deploy to be called once"

      assert.isTrue updateCodeStub.calledWith(tagName),
        "Expected Deploy.deploy to be called with the tag name"

      done()
    catch e
      done(e)
    finally
      sandbox.restore()

  ).fail( (err) ->
    console.error err
    sandbox.restore()
    done(err)
  )
)

test("POST deploy fails given tagname doesn't refer to this
server", (done) ->
  sandbox = sinon.sandbox.create()

  deployRole = 'staging'
  commitHookPayload = {
    "ref": "#{deployRole}-test-webhooks-1bcc7a0470",
    "ref_type": "tag"
  }

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> true)

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->)

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'deploy'
      return server_name: 'not staging'
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: commitHookPayload
    }
  ).spread( (res, body) ->

    try
      assert.strictEqual updateCodeStub.callCount, 0,
        "Expected CommandRunner.spawn to not be called once"

      assert.equal res.statusCode, 500
      done()
    catch e
      done(e)
    finally
      sandbox.restore()

  ).fail( (err) ->
    sandbox.restore()
    done(err)
  )
)

test("POST deploy fails if the IP is not of GitHub's servers", (done) ->
  sandbox = sinon.sandbox.create()

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> false)

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->)

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: {}
    }
  ).spread( (res, body) ->

    try
      console.log body
      assert.equal res.statusCode, 401

      assert.isFalse updateCodeStub.calledOnce,
        "Expected CommandRunner.spawn not to be called"

      done()
    catch err
      done(err)
    finally
      sandbox.restore()

  ).fail( (err) ->
    sandbox.restore()
    done(err)
  )
)
