assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
request = require 'request'
Promise = require 'bluebird'
AppConfig = require('../../initializers/config')

GitHubDeploy = require('../../lib/git_hub_deploy')

defaultHeaders =
  'Accept': 'application/vnd.github.cannonball-preview+json'
  'User-Agent': 'National Reporting Toolkit Deployment Bot 2000x'


suite('GitHubDeploy')

test('#githubConfig returns the github basic auth config from the config file', ->
  expectedGithubConfig =
    username: 'abcd'
    password: 'x-oauth-basic'

  appConfigStub = sinon.stub(AppConfig, 'get', (key) ->
    return {
      github: expectedGithubConfig
    }
  )

  try
    githubConfig = GitHubDeploy.githubConfig()

    assert.deepEqual githubConfig, expectedGithubConfig,
      "Expected correct github config to be returned"
  finally
    appConfigStub.restore()
)

test('#githubConfig throws an appropriate error if no config found', ->

  appConfigStub = sinon.stub(AppConfig, 'get', (key) ->
    return { }
  )

  try
    assert.throws((->
      githubConfig = GitHubDeploy.githubConfig()
    ), "Unable to find 'deploy.github' attribute in config")

  finally
    appConfigStub.restore()
)

test(".start creates a GitHub deploy for the given tag name", (done)->
  tagName = "be-suited-bananana"
  newDeployId = 10

  sandbox = sinon.sandbox.create()

  postStub = sandbox.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 201, body: JSON.stringify({id: newDeployId})})
  )

  appConfigStub = sandbox.stub(AppConfig, 'get', (key) ->
    return {
      github:
        username: 'abcd'
        password: 'x-oauth-basic'
    }
  )

  deploy = new GitHubDeploy(tagName)

  deploy.start().then(->
    expectedRequestParams =
      url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
      headers: defaultHeaders
      auth: {
        username: 'abcd'
        password: 'x-oauth-basic'
      }
      body: JSON.stringify({
        "description": tagName,
        "payload": {},
        "ref": tagName,
        "force": true
      })

    try
      assert.isTrue(
        postStub.calledWith(expectedRequestParams),
        """Expected a create deploy command to be sent to github"""
      )

      assert.strictEqual deploy.id, newDeployId,
        "Expected the deploy to store the ID from the create"

      done()

    catch err
      done(err)
    finally
      sandbox.restore()

  ).catch((err)->
    sandbox.restore()
    done(err)
  )
)

test('.start throws an error if Github responds with an error', (done) ->
  errorResponse = JSON.stringify({message: "Not found"})

  sandbox = sinon.sandbox.create()

  postStub = sandbox.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 404, body: errorResponse})
  )

  appConfigStub = sandbox.stub(AppConfig, 'get', (key) ->
    return github: {}
  )

  deploy = new GitHubDeploy("fancy-banana-stand")

  deploy.start().then(->
    sandbox.restore()
    done(new Error("Expected deploy.start to throw an error"))
  ).catch( (err)->
    try

      assert.deepEqual err, {"message": "Not found"},
        "Expected deploy.start() to throw the error returned by github"

      done()

    catch err
      done(err)
    finally
      sandbox.restore()
  )
)

test('.updateDeployState posts the given state and description to
 github', (done) ->
  sandbox = sinon.sandbox.create()

  deployId = 4
  postStub = sandbox.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 201})
  )

  auth = {
    username: 'abcd'
    password: 'x-oauth-basic'
  }

  appConfigStub = sandbox.stub(GitHubDeploy, 'githubConfig', (key) ->
    return auth
  )

  deploy = new GitHubDeploy()

  deploy.id = deployId

  state = 'pending'
  description = 'Printer is on fire'

  deploy.updateDeployState(state, description).then(->
    expectedGitHubQuery =
      url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{deployId}/statuses"
      headers: defaultHeaders
      auth: auth
      body: JSON.stringify(
        state: state
        description: description
      )

    try
      assert.deepEqual(
        postStub.getCall(0).args[0],
        expectedGitHubQuery,
        "Expected a status update to be sent to github"
      )

      done()

    catch err
      done(err)
    finally
      sandbox.restore()

  ).catch((err)->
    sandbox.restore()
    done(err)
  )
)

test('.updateDeployState throws an error if Github responds with an error', (done) ->
  sandbox = sinon.sandbox.create()

  errorResponse = JSON.stringify({message: "Not found"})
  postStub = sandbox.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 404, body: errorResponse})
  )

  appConfigStub = sandbox.stub(GitHubDeploy, 'githubConfig', (key) ->
    return {}
  )

  deploy = new GitHubDeploy("fancy-banana-stand")

  deploy.updateDeployState("pending", "hey, here's a deploy").then(->
    sandbox.restore()
    done(new Error("Expected deploy.updateDeployState to throw an error"))
  ).catch( (err)->
    try

      assert.deepEqual err, {"message": "Not found"},
        "Expected deploy.updateDeployState() to throw the error returned by github"

      done()

    catch err
      done(err)
    finally
      sandbox.restore()
  )
)

test("#getDeployForTag queries github for deployments and resolves
with a deploy instance with the correct ID", (done) ->
  deployId = 345
  tagName = 'hippy-banana'

  sandbox = sinon.sandbox.create()

  getStub = sandbox.stub(request, 'get', (options, cb)->
    response =
      body: JSON.stringify([{
        id: deployId
        description: tagName
      }, {
        id: 432789423
        description: 'corporate-banana'
      }])
    cb(null, response)
  )

  githubConf = {dummy: 'config'}
  appConfigStub = sandbox.stub(GitHubDeploy, 'githubConfig', (key) ->
    return githubConf
  )

  GitHubDeploy.getDeployForTag(tagName).then((deploy) ->
    try
      assert.strictEqual deploy.constructor.name, 'GitHubDeploy',
        "Expected the returned object to be an instance of GitHubDeploy"

      assert.strictEqual deploy.id, deployId,
        "Expected the returned deploy instance to have the correct ID"

      assert.isTrue getStub.calledOnce,
        "Expected request.get to be called"

      requestArgs = getStub.getCall(0).args

      assert.strictEqual(
        requestArgs[0].url,
        "https://api.github.com/repos/unepwcmc/NRT/deployments",
        "Expected a request to be sent to right URL"
      )

      assert.deepEqual(
        requestArgs[0].headers,
        defaultHeaders,
        "Expected the github headers to be set"
      )

      assert.deepEqual(
        requestArgs[0].auth,
        githubConf,
        "Expected the github auth to be sent"
      )

      done()
    catch err
      done(err)
    finally
      sandbox.restore()
  ).catch((err) ->
    sandbox.restore()
    done(err)
  )

)

test("#getDeployForTag polls github for deployments if 
deployment not included in first result", (done) ->
  deployId = 345
  tagName = 'hippy-banana'

  clock = sinon.useFakeTimers()
  sandbox = sinon.sandbox.create()

  requestCount = 0

  noDeployResponse = {
    body: JSON.stringify([])
  }
  deployResponse = {
    body: JSON.stringify([
      id: deployId
      description: tagName
    ])
  }
  responses = [noDeployResponse, deployResponse]

  getStub = sandbox.stub(request, 'get', (options, cb)->
    response = responses[requestCount]
    requestCount += 1
    cb(null, response)
  )

  appConfigStub = sandbox.stub(GitHubDeploy, 'githubConfig', (key) ->
    return {}
  )

  GitHubDeploy.getDeployForTag(tagName).then((deploy) ->
    try
      assert.strictEqual deploy.id, deployId,
        "Expected the returned deploy instance to have the correct ID"

      assert.strictEqual getStub.callCount, 2,
        "Expected 2 requests to be made to github"

      done()
    catch err
      done(err)
    finally
      sandbox.restore()
  ).catch((err) ->
    sandbox.restore()
    done(err)
  )

  # Skip to second poll
  clock.tick(1000)
  clock.restore()

)

test(".pollStatus polls and prints deploy status until success", (done)->
  deploy = new GitHubDeploy()
  deploy.id = 5

  clock = sinon.useFakeTimers()
  sandbox = sinon.sandbox.create()

  requestCount = 0

  pendingStatusResponse = {
    id: 1
    state: "pending"
    description: "Fetching something or rather"
    created_at: "2014-03-04T10:08:32Z"
  }
  finishedStatusResponse = {
    id: 2
    state: "finished"
    description: "totally done"
    created_at: "2014-03-04T10:09:00Z"
  }
  responses = [{
    body: JSON.stringify(
      [pendingStatusResponse]
    )
  }, {
    body: JSON.stringify(
      [pendingStatusResponse, finishedStatusResponse]
    )
  }]

  getStub = sandbox.stub(request, 'get', (options, cb)->
    response = responses[requestCount]
    requestCount += 1
    cb(null, response)
  )

  logSpy = sandbox.spy(console, 'log')

  githubConf = {dummy: 'config'}
  appConfigStub = sandbox.stub(GitHubDeploy, 'githubConfig', (key) ->
    return githubConf
  )

  deploy.pollStatus().then(->
    try
      expectedLogs = [
        "[#{pendingStatusResponse.created_at}] pending: #{pendingStatusResponse.description}"
        "[#{finishedStatusResponse.created_at}] finished: #{finishedStatusResponse.description}"
      ]

      for message, index in expectedLogs
        logCall = logSpy.getCall(index)

        unless logCall?
          return done(new Error("Couldn't find console.log call for #{message}"))

        assert.strictEqual(
          logCall.args[0], message,
          "Expected console.log to be called with message"
        )

      assert.strictEqual(logSpy.callCount, expectedLogs.length,
        "Wrong number of console.log calls"
      )

      assert.isTrue getStub.calledTwice,
        "Expected request.get to be called twice"

      requestArgs = getStub.getCall(0).args

      assert.strictEqual(
        requestArgs[0].url,
        "https://api.github.com/repos/unepwcmc/NRT/deployments/#{deploy.id}/statuses",
        "Expected a request to be sent to right URL"
      )

      assert.deepEqual(
        requestArgs[0].headers,
        defaultHeaders,
        "Expected the github headers to be set"
      )

      assert.deepEqual(
        requestArgs[0].auth,
        githubConf,
        "Expected the github auth to be sent"
      )

      done()

    catch err
      done(err)
    finally
      sandbox.restore()

  ).catch((err) ->
    sandbox.restore()
    done(err)
  )

  # Skip to second poll
  clock.tick(1000)
  clock.restore()
)

test(".pollStatus polls rejects the returned promise if a failure state
is encountered", (done)->
  deploy = new GitHubDeploy()
  deploy.id = 5

  sandbox = sinon.sandbox.create()

  failedResponse = {
    id: 1
    state: "failure"
    description: "PC Load Letter"
    created_at: "2014-03-04T10:08:32Z"
  }

  getStub = sandbox.stub(request, 'get', (options, cb)->
    response =
      body: JSON.stringify([
        failedResponse
      ])
    cb(null, response)
  )

  logSpy = sandbox.spy(console, 'log')

  appConfigStub = sandbox.stub(GitHubDeploy, 'githubConfig', (key) ->
    return {}
  )

  deploy.pollStatus().then(->
    try
      expectedLog = "[#{failedResponse.created_at}] failure: #{failedResponse.description}"

      logCall = logSpy.getCall(0)

      unless logCall?
        throw new Error("Couldn't find console.log call for #{expectedLog}")

      assert.strictEqual(
        logCall.args[0], expectedLog,
        "Expected console.log to be called with #{expectedLog}"
      )

      assert.strictEqual(logSpy.callCount, 1,
        "Expects console.log to be called only once"
      )
      done()

    catch err
      done(err)
    finally
      sandbox.restore()

  ).catch((err) ->
    sandbox.restore()
    done(err)
  )
)
