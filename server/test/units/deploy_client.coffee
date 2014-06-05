assert = require('chai').assert
sinon = require 'sinon'
request = require 'request'
Promise = require 'bluebird'
crypto = require('crypto')

CommandRunner = require('../../lib/command_runner')
Git = require('../../lib/git')
GitHubDeploy = require('../../lib/git_hub_deploy')
DeployClient = require('../../lib/deploy_client')

suite('Deploy Client')

test(".start creates a new tag from arguments and polls its deploy(s) state", (done) ->
  target = 'staging'
  description = 'New feature stuff'

  sandbox = sinon.sandbox.create()

  printedLogs = []
  sandbox.stub(console, 'log', (log) ->
    printedLogs.push(log)
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

  getDeploysCallCount = 0
  deploysForFirstCall = [{
    id: 1
    server:
      name: 'test-server'
    statuses: [
      {createdAt: "08:05", state: "pending", description: "Being deployed"}
    ]
    getResolution: (-> null)
    isCompleted: (-> false)
    populateStatuses: sandbox.spy(-> Promise.resolve())
  }]

  deploysForSecondCall = [{
    id: 1
    server:
      name: 'test-server'
    statuses: [
      {createdAt: "08:05", state: "pending", description: "Being deployed"},
      {createdAt: "08:07", state: "success", description: "Deployed"},
    ]
    getResolution: (-> "success")
    isCompleted: (-> true)
    populateStatuses: sandbox.spy(-> Promise.resolve())
  }, {
    id: 2
    server:
      name: 'test-server-2'
    statuses: [
      {createdAt: "08:06", state: "pending", description: "Being deployed"}
      {createdAt: "08:08", state: "success", description: "Deployed"}
    ]
    getResolution: (-> "sucess")
    isCompleted: (-> true)
    populateStatuses: sandbox.spy(-> Promise.resolve())
  }]

  deploys = [deploysForFirstCall, deploysForSecondCall]

  getDeploysStub = sandbox.stub(GitHubDeploy, 'getDeploysForTag', ->
    promise = Promise.resolve(deploys[getDeploysCallCount])
    getDeploysCallCount += 1
    promise
  )

  expectedLogs = [
    "Creating tag 'deploy-staging-new-feature-stuff-4'",
    "[ <test-server> - 08:05 ] pending: Being deployed",
    "[ <test-server> - 08:07 ] success: Deployed",
    "[ <test-server-2> - 08:06 ] pending: Being deployed",
    "[ <test-server-2> - 08:08 ] success: Deployed",
    "Deploy to test-server success",
    "Deploy to test-server-2 sucess"
  ]

  client = new DeployClient()
  client.start(target, description).then( ->
    expectedBranchName = "deploy-staging-new-feature-stuff-#{randomNumber}"

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

    assert.strictEqual getDeploysStub.callCount, 2,
      "Expected GitHubDeploy to be called twice"

    assert.isTrue getDeploysStub.calledWith(expectedBranchName),
      """
      Expected GitHubDeploy.getDeploysForTag to be called
      with #{expectedBranchName}, but called with
      #{getDeploysStub.getCall(0).args}
      """

    assert.deepEqual printedLogs, expectedLogs,
      "Expected the deployments statuses to be logged"

    sandbox.restore()
    done()
  ).catch( (err) ->
    sandbox.restore()
    done(err)
  )

  # setTimeout is used here to stop sinon.useFakeTimers from blocking time
  # immediately. We need DeployClient to breathe a bit, as it is
  # setting a timeout in the middle of the algorithm.
  setTimeout( ->
    clock = sinon.useFakeTimers()
    clock.tick(2000)
    clock.restore()
  , 100)
)
