assert = require('chai').assert
helpers = require '../../helpers'
sinon = require 'sinon'
readline = require 'readline'
request = require 'request'
Promise = require 'bluebird'
crypto = require('crypto')


CommandRunner = require('../../../lib/command_runner')
Git = require('../../../lib/git')
GitHubDeploy = require('../../../lib/git_hub_deploy')

suite('Deploy')

test("Asks for the server target and tag name,
  then creates a new tag and polls it's deploy state", (done) ->
  readlineCount = 0
  responses = ['staging', 'New feature stuff']

  sandbox = sinon.sandbox.create()

  sandbox.stub(readline, 'createInterface', ->
    once: (event, callback) ->
      readlineCount += 1
      callback(responses[readlineCount-1])
  )

  # Determined by dice roll, guaranteed to be random
  randomNumber = 4
  randomStub = sandbox.stub(crypto, 'randomBytes', ->
    toString: ->
      randomNumber
  )

  createTagStub = sandbox.stub(Git, 'createTag', ->
    new Promise((resolve, reject) -> resolve())
  )

  pushTagStub = sandbox.stub(Git, 'push', ->
    new Promise((resolve, reject) -> resolve())
  )

  deploy =
    server:
      name: 'test-server'
    pollStatus: sandbox.spy(->
      Promise.resolve({
        deploy:
          server:
            name: 'test-server'
        resolution: 'success'
      })
    )

  getDeploysStub = sandbox.stub(GitHubDeploy, 'getDeploysForTag', ->
    new Promise((resolve) ->
      resolve([deploy])
    )
  )

  require('../../../lib/tasks/deploy')().then( ->
    expectedBranchName = "staging-new-feature-stuff-#{randomNumber}"

    assert.isTrue(
      createTagStub.calledWith(
        expectedBranchName, 'New feature stuff'
      ),
      "Expected Git.createTag to be called
      with #{expectedBranchName}, 'New feature stuff', but was called with
      #{createTagStub.getCall(0).args}"
    )

    assert.isTrue(
      pushTagStub.calledWith(expectedBranchName),
      """
        Expected the created tag to be pushed with #{expectedBranchName}
        but called with #{pushTagStub.getCall(0).args}
      """
    )

    assert.isTrue getDeploysStub.calledOnce,
      "Expected GitHubDeploy to be called once"

    assert.isTrue getDeploysStub.calledWith(expectedBranchName),
      """
      Expected GitHubDeploy.getDeploysForTag to be called
      with #{expectedBranchName}, but called with
      #{getDeploysStub.getCall(0).args}
      """

    sandbox.restore()
    done()
  ).catch( (err) ->
    sandbox.restore()
    done(err)
  )
)
