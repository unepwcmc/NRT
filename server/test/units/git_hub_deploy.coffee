assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
request = require 'request'
Promise = require 'bluebird'

GitHubDeploy = require('../../lib/git_hub_deploy')

suite('GitHubDeploy')

test(".start creates a GitHub deploy for the given tag name", (done)->
  tagName = "be-suited-bananana"
  newDeployId = 10

  postStub = sinon.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 200, body: JSON.stringify({id: newDeployId})})
  )

  deploy = new GitHubDeploy(tagName)

  deploy.start().then(->
    expectedRequestParams =
      url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
      headers: {
        'Accept': 'application/vnd.github.cannonball-preview+json'
        'User-Agent': 'National Reporting Toolkit Deployment Bot 2000x'
      }
      body: JSON.stringify({"description": tagName, "payload": {}, "ref": tagName})

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
      postStub.restore()

  ).catch((err)->
    postStub.restore()
    done(err)
  )
)

test('.start throws an error if Github responds with an error', (done) ->
  errorResponse = JSON.stringify({message: "Not found"})
  postStub = sinon.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 404, body: errorResponse})
  )

  deploy = new GitHubDeploy("fancy-banana-stand")

  deploy.start().then(->
    postStub.restore()
    done(new Error("Expected deploy.start to throw an error"))
  ).catch( (err)->
    try

      assert.deepEqual err, {"message": "Not found"},
        "Expected deploy.start() to throw the error returned by github"

      done()

    catch err
      done(err)
    finally
      postStub.restore()
  )
)

test('.updateDeployState posts the given state and description to
 github', (done) ->
  deployId = 4
  postStub = sinon.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 200})
  )

  deploy = new GitHubDeploy()

  deploy.id = deployId

  state = 'pending'
  description = 'Printer is on fire'

  deploy.updateDeployState(state, description).then(->
    expectedGitHubQuery =
      url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{deployId}/statuses"
      headers: {
        'Accept': 'application/vnd.github.cannonball-preview+json'
        'User-Agent': 'National Reporting Toolkit Deployment Bot 2000x'
      }
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
      postStub.restore()

  ).catch((err)->
    postStub.restore()
    done(err)
  )
)

test('.updateDeployState throws an error if Github responds with an error', (done) ->
  errorResponse = JSON.stringify({message: "Not found"})
  postStub = sinon.stub(request, 'post', (options, cb) ->
    cb(null, {statusCode: 404, body: errorResponse})
  )

  deploy = new GitHubDeploy("fancy-banana-stand")

  deploy.updateDeployState("pending", "hey here's a deploy").then(->
    postStub.restore()
    done(new Error("Expected deploy.updateDeployState to throw an error"))
  ).catch( (err)->
    try

      assert.deepEqual err, {"message": "Not found"},
        "Expected deploy.updateDeployState() to throw the error returned by github"

      done()

    catch err
      done(err)
    finally
      postStub.restore()
  )
)
