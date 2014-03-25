assert = require('chai').assert
sinon  = require 'sinon'

ConfigureTask = require '../../../lib/tasks/configure'

MessageServer = require '../../../lib/message_server'
fs = require 'fs'
Redis = require('redis')

suite 'Configure Application'

test(".start reads in and publishes questions to a MessageServer and
 subscribes to a 'done' event", ->
  sandbox = sinon.sandbox.create()

  expectedQuestions = [{
    question: "Has anyone really been far even as decided to use even go want to do look more like?"
    id: "has_anyone"
    type: 'input'
  }]
  readFileStub = sandbox.stub(fs, 'readFileSync', ->
    JSON.stringify(expectedQuestions)
  )

  onMessageStub = sandbox.stub(MessageServer::, 'on', ->)
  publishStub = sandbox.stub(MessageServer::, 'publish', ->)

  redisClient =
    publish: ->
    subscribe: ->
  createClientStub = sandbox.stub(Redis, 'createClient', -> redisClient)

  try
    ConfigureTask.start()

    assert.strictEqual readFileStub.callCount, 1,
      "Expected fs.readFileSync to be called once"

    readFileArgs = readFileStub.getCall(0).args
    assert.match readFileArgs[0], new RegExp("config/config_questions.json"),
      "Expected fs.readFileSync to be called with the question config path"

    assert.strictEqual onMessageStub.callCount, 2,
      "Expected messageServer.on to be called twice"

    assert.strictEqual onMessageStub.getCall(0).args[0], "answer",
      "Expected a callback to be bound to the MessageServer 'answer' event"
    assert.strictEqual onMessageStub.getCall(1).args[0], "done",
      "Expected a callback to be bound to the MessageServer 'done' event"

    assert.strictEqual publishStub.callCount, 1,
      "Expected messageServer.publish to be called once"

    publishArgs = publishStub.getCall(0).args
    assert.strictEqual publishArgs[0], 'questions',
      "Expected the questions to be published to the MessageServer with the type 'questions'"

    assert.deepEqual publishArgs[1], expectedQuestions,
      "Expected the questions to be published to the MessageServer"
  finally
    sandbox.restore()
)
