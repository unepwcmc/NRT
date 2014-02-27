assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
fs = require('fs')
sinon = require('sinon')
Q = require('q')

CommandRunner = require('../../bin/command-runner')
AppConfig = require('../../initializers/config')
range_check = require('range_check')

suite('Deploy')

test('POST /deploy with a github payload for new deploy tag which refers
to the same role as the server causes the server to trigger the deploy
command', (done) ->
  sandbox = sinon.sandbox.create()

  deployRole = 'staging'
  commitHookPayload = {
    "ref": "#{deployRole}-test-webhooks-1bcc7a0470",
    "ref_type": "tag"
  }

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> true)

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'server_name'
      return deployRole
  )

  commandSpawnStub = sandbox.stub(CommandRunner, 'spawn', ->
    return {on: ->}
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

      assert.strictEqual commandSpawnStub.callCount, 1,
        "Expected CommandRunner.spawn to be called once"

      assert.isTrue(
        commandSpawnStub.calledWith(
          "coffee #{process.cwd()}/bin/deploy.coffee"
        ),
        "Expected CommandRunner.spawn to call the deploy command"
      )

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

  commandSpawnStub = sandbox.stub(CommandRunner, 'spawn', ->
    return {on: ->}
  )

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'server_name'
      return 'not staging'
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: commitHookPayload
    }
  ).spread( (res, body) ->

    try
      assert.strictEqual commandSpawnStub.callCount, 0,
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

  commandSpawnStub = sandbox.stub(CommandRunner, 'spawn', ->
    return {on: ->}
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: {}
    }
  ).spread( (res, body) ->

    try
      assert.equal res.statusCode, 401

      assert.isFalse commandSpawnStub.calledOnce,
        "Expected CommandRunner.spawn not to be called"

      done()
    catch err
      done(e)
    finally
      sandbox.restore()

  ).fail( (err) ->
    sandbox.restore()
    done(err)
  )
)
