assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
fs = require('fs')
sinon = require('sinon')
Q = require('q')

CommandRunner = require('../../bin/command-runner')
AppConfig = require('../../initializers/config')
DeployController = require('../../controllers/deploy')
Deploy = require('../../lib/deploy')
GITHUB_IP = "192.30.252.0"

suite('Deploy Controller')

test('.index calls Deploy.deploy when receiving a request with an
 x_real_ip from github, it deploys', (done) ->
  sandbox = sinon.sandbox.create()

  ref = 'some-tag'

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->
    then: ->
      catch: ->
  )
  sandbox.stub(AppConfig, 'get', ->
    ref
  )

  fakeReq =
    headers:
      "x-real-ip": GITHUB_IP
    body:
      ref: ref

  fakeRes =
    send: (responseCode, message) ->
      console.log "In fake res.send"
      try
        assert.strictEqual(responseCode, 200,
          "Expected the request to succeed")

        assert.strictEqual 1, updateCodeStub.callCount,
          "Expected Deploy.deploy to be called once"

        done()
      catch err
        done(err)
      finally
        sandbox.restore()

  DeployController.index(fakeReq, fakeRes)
)

test('.index calls Deploy.deploy when receiving a request without
 the x_real_ip (nginx) header, but a github IP in
 req.connection.remoteAddress', (done) ->
  sandbox = sinon.sandbox.create()

  ref = 'some-tag'

  updateCodeStub = sandbox.stub(Deploy, 'deploy', ->
    then: ->
      catch: ->
  )
  sandbox.stub(AppConfig, 'get', ->
    ref
  )

  fakeReq =
    body:
      ref: ref
    headers: {}
    connection:
      remoteAddress: GITHUB_IP

  fakeRes =
    send: (responseCode, message) ->
      console.log "In fake res.send"
      try
        assert.strictEqual(responseCode, 200,
          "Expected the request to succeed")

        assert.strictEqual 1, updateCodeStub.callCount,
          "Expected Deploy.deploy to be called once"

        done()
      catch err
        done(err)
      finally
        sandbox.restore()

  DeployController.index(fakeReq, fakeRes)
)
