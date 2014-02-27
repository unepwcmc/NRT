assert = require('chai').assert
helpers = require '../../helpers'
sinon = require 'sinon'
request = require 'request'
Promise = require 'bluebird'

CommandRunner = require('../../../bin/command-runner')
Git = require('../../../lib/git')
Deploy = require('../../../lib/deploy')

suite('Deploy')

test('.updateFromTag Sets the gits username,
pulls the given tag,
runs npm install in both client and server', (done) ->
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

  Deploy.updateFromTag(tagName).then( ->
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


test('.deploy checkouts the given tag', (done) ->
  sandbox = sinon.sandbox.create()
  tagName = 'twiki'
  updateStub = sandbox.stub(Deploy, 'updateFromTag', ->
    new Promise((resolve)-> resolve())
  )

  Deploy.deploy(tagName).then(->
    try
      assert.isTrue(
        updateStub.calledWith(tagName),
        "Expected Deploy.updateFromtag to be called with teh tagname"
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
