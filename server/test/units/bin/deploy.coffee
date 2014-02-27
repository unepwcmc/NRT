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

  gitPullStub = sandbox.stub(Git, 'pull', ->
    new Promise((resolve)-> resolve())
  )

  Deploy.updateFromTag(tagName).then( ->
    try
      assert.isTrue(
        gitSetEmailStub.calledWith('deploy@nrt.io'),
        "Expected the git email to be set to deploy@nrt.io"
      )

      assert.isTrue(
        gitPullStub.calledWith(tagName),
        "Expected the given tag to be pulled"
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
