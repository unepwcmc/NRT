assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
fs = require('fs')
sinon = require('sinon')
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
  tagName = "deploy-#{deployRole}-test-webhooks-1bcc7a0470"
  commitHookPayload = {
    "ref": tagName,
    "ref_type": "tag"
  }

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> true)

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'server'
      return name: deployRole
  )

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->
    new Promise(() ->)
  )

  Promise.promisify(request.post, request)({
    url: helpers.appurl('/deploy')
    json: true
    body: commitHookPayload
  }).spread( (res, body) ->

    assert.equal res.statusCode, 200,
      "Expected the request to succeed"

    assert.strictEqual updateCodeStub.callCount, 1,
      "Expected Deploy.deploy to be called once"

    assert.isTrue updateCodeStub.calledWith(tagName),
      "Expected Deploy.deploy to be called with the tag name"

    sandbox.restore()
    done()
  ).catch( (err) ->
    sandbox.restore()
    done(err)
  )
)

test("POST deploy fails given tagname doesn't refer to this
server", (done) ->
  sandbox = sinon.sandbox.create()

  differentDeployRole = 'staging'
  commitHookPayload = {
    "ref": "deploy-#{differentDeployRole}-test-webhooks-1bcc7a0470",
    "ref_type": "tag"
  }

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> true)

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->)

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'server'
      return name: 'not staging'
  )

  Promise.promisify(request.post, request)({
    url: helpers.appurl('/deploy')
    json: true
    body: commitHookPayload
  }).spread( (res, body) ->

    assert.strictEqual updateCodeStub.callCount, 0,
      "Expected CommandRunner.spawn to not be called once"

    assert.equal res.statusCode, 500

    sandbox.restore()
    done()

  ).catch( (err) ->
    sandbox.restore()
    done(err)
  )
)

test("POST deploy fails given tagname doesn't start with 'deploy-'", (done) ->
  sandbox = sinon.sandbox.create()

  deployRole = 'staging'
  commitHookPayload = {
    "ref": "#{deployRole}-test-webhooks-1bcc7a0470",
    "ref_type": "tag"
  }

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> true)

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->)

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'server'
      return name: deployRole
  )

  Promise.promisify(request.post, request)({
    url: helpers.appurl('/deploy')
    json: true
    body: commitHookPayload
  }).spread( (res, body) ->

    assert.strictEqual updateCodeStub.callCount, 0,
      "Expected CommandRunner.spawn to not be called once"

    assert.equal res.statusCode, 500

    sandbox.restore()
    done()

  ).catch( (err) ->
    sandbox.restore()
    done(err)
  )
)

test("POST deploy fails if the IP is not of GitHub's servers", (done) ->
  sandbox = sinon.sandbox.create()

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> false)

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->)

  Promise.promisify(request.post, request)({
    url: helpers.appurl('/deploy')
    json: true
    body: {}
  }).spread( (res, body) ->

    console.log body
    assert.equal res.statusCode, 401

    assert.isFalse updateCodeStub.calledOnce,
      "Expected CommandRunner.spawn not to be called"

    sandbox.restore()
    done()

  ).catch( (err) ->
    sandbox.restore()
    done(err)
  )
)


test('POST /deploy with a github payload for new deploy tag which refers
to at least one of the tags given to the server causes the server to
trigger the deploy command', (done) ->
  sandbox = sinon.sandbox.create()

  deployingTags = ['staging', 'a_tag']
  tagName = "deploy-#{deployingTags.join(',')}-test-webhooks-1bcc7a0470"
  commitHookPayload = {
    "ref": tagName,
    "ref_type": "tag"
  }

  rangeCheckStub = sandbox.stub(range_check, 'in_range', -> true)

  configStub = sandbox.stub(AppConfig, 'get', (variable)->
    if variable is 'server'
      return name: 'doesnt_really_matter_now'
    if variable is 'deploy'
      return tags: ['another_tag', 'staging']
  )

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->
    new Promise(() ->)
  )

  Promise.promisify(request.post, request)({
    url: helpers.appurl('/deploy')
    json: true
    body: commitHookPayload
  }).spread( (res, body) ->

    assert.equal res.statusCode, 200,
      "Expected the request to succeed"

    assert.strictEqual updateCodeStub.callCount, 1,
      "Expected Deploy.deploy to be called once"

    assert.isTrue updateCodeStub.calledWith(tagName),
      "Expected Deploy.deploy to be called with the tag name"

    sandbox.restore()
    done()
  ).catch( (err) ->
    sandbox.restore()
    done(err)
  )
)

