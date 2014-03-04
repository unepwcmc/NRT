assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
request = require 'request'
Promise = require 'bluebird'

CommandRunner = require('../../bin/command-runner')
Git = require('../../lib/git')
GitHubDeploy = require('../../lib/git_hub_deploy')
Deploy = require('../../lib/deploy')

suite('Deploy')

test('.updateFromTag sets the gits username,
pulls the given tag,
runs npm install in both client and server,
notifying github at each step', (done) ->
  sandbox = sinon.sandbox.create()

  tagName = "corporate-banana"

  gitSetEmailStub = sandbox.stub(Git, 'setEmail', ->
    new Promise((resolve)-> resolve())
  )

  gitFetchStub = sandbox.stub(Git, 'fetch', ->
    new Promise((resolve)-> resolve())
  )

  gitCheckoutStub = sandbox.stub(Git, 'checkout', ->
    new Promise((resolve)-> resolve())
  )

  deploy = {
    updateDeployState: sandbox.spy(->
      new Promise((resolve)-> resolve())
    )
  }


  Deploy.updateFromTag(tagName, deploy).then( ->
    try
      assert.isTrue(
        gitSetEmailStub.calledWith('deploy@nrt.io'),
        "Expected the git email to be set to deploy@nrt.io"
      )

      assert.isTrue(
        gitFetchStub.calledOnce,
        "Expected git fetch to be called"
      )

      assert.isTrue(
        gitCheckoutStub.calledWith(tagName),
        "Expected the fetched tag to be checked out"
      )

      assert.isTrue(
        deploy.updateDeployState.calledWith('pending', 'Fetching tags'),
        "Expected github to be notified of fetching tags"
      )

      assert.isTrue(
        deploy.updateDeployState.calledWith('pending', "Checking out tag '#{tagName}'"),
        "Expected github to be notified of tag checkout  "
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


test('.deploy starts a new deploy and
checks out the given tag', (done) ->
  sandbox = sinon.sandbox.create()
  tagName = 'twiki'

  updateStub = sandbox.stub(Deploy, 'updateFromTag', ->
    new Promise((resolve)-> resolve())
  )
  startGithubDeployStub = sandbox.stub(GitHubDeploy::, 'start', ->
    new Promise((resolve)->
      @id = 5
      resolve()
    )
  )

  Deploy.deploy(tagName).then(->
    try
      assert.isTrue(
        startGithubDeployStub.calledOnce,
        "Expected GitHubDeploy::start to be called"
      )

      assert.isTrue(
        updateStub.calledWith(tagName),
        "Expected Deploy.updateFromtag to be called with the tagname"
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

test('.deploy posts the error status if an error occurs', (done) ->
  sandbox = sinon.sandbox.create()

  sandbox.stub(GitHubDeploy::, 'start', ->
    new Promise((resolve)->
      @id = 5
      resolve()
    )
  )

  updateDeployStateStub = sandbox.stub(GitHubDeploy::, 'updateDeployState', ->
    new Promise((resolve) -> resolve())
  )

  failure = new Error("Big end has gone")
  sandbox.stub(Deploy, 'updateFromTag', ->
    new Promise((resolve, reject) -> reject(failure))
  )

  Deploy.deploy().then(->
    sandbox.restore()
    done(new Error("Deploy should fail"))
  ).catch((err)->
    try
      assert.strictEqual err.message, failure.message,
        "Expected the right error to be thrown"

      assert.isTrue updateDeployStateStub.calledOnce,
        "Expected updateDeployState to be called"

      updateDeployStateCall = updateDeployStateStub.getCall(0)
      assert.isTrue updateDeployStateStub.calledWith('failure', failure.message),
        """
        Expected updateDeployState to be called with
        'failure', #{failure.message}, but called with
        #{updateDeployStateCall.args}
      """

      done()
    catch assertErr
      done(assertErr)
    finally
      sandbox.restore()
  )

)
