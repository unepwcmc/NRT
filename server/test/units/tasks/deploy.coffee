assert = require('chai').assert
helpers = require '../../helpers'
sinon = require 'sinon'
readline = require 'readline'
request = require 'request'

suite('Deploy')

test('Asks for the server target and tag name, then creates a new tag', (done) ->
  readlineCount = 0
  responses = ['staging', 'New feature']

  sinon.stub(readline, 'createInterface', ->
    once: (event, callback) ->
      readlineCount += 1
      callback(responses[readlineCount-1])
  )

  requestStub = sinon.stub(request, 'post', (options, callback)->
    callback(null, {
      body: JSON.stringify({message: 'ok'})
    })
  )

  require('../../../lib/tasks/deploy').then(->
    try
      theRequest = requestStub.firstCall

      assert.isNotNull theRequest, "Expected a post request to be sent"

      requestArgs = theRequest.args

      assert.strictEqual(
        "https://api.github.com/v3/repos/unepwcmc/NRT/releases",
        requestArgs[0].url,
        "Expected the deploy command to post a new release to github"
      )

      expectPayload = {
        "tag_name": "staging-new-feature",
        "name": "New feature",
        "body": "New feature",
      }

      assert.deepEqual requestArgs[0].json, expectPayload,
        "Expected the right payload to be sent to github"

      done()

    catch err
      done(err)
    finally
      requestStub.restore()

  ).catch(done)
)
