assert = require('chai').assert
sinon  = require 'sinon'

MessageServer = require '../../lib/message_server'
Redis = require('redis')

test('new MessageServer subscribes to a queue with a given server ID', ->
  serverId = 'abcd123'

  subscribeStub = sinon.stub(MessageServer::, 'subscribe', ->)

  try
    messageServer = new MessageServer(serverId: serverId)

    assert.strictEqual subscribeStub.callCount, 1,
      "Expected MessageServer.subscribe to be called once"

    assert.property messageServer, 'serverId',
      "Expected message server to have a server ID property"

    assert.strictEqual messageServer.serverId, serverId,
      "Expected message server id to be #{serverId}, but was #{messageServer.serverId}"
  finally
    subscribeStub.restore()
)

test('.subscribe subscribes to the redis channel with the server ID', ->
  clientSpy = sinon.spy()
  redisClient =
    subscribe: clientSpy
  createClientStub = sinon.stub(Redis, 'createClient', -> redisClient)

  serverId = '123'

  try
    messageServer = new MessageServer(serverId: serverId)

    assert.strictEqual createClientStub.callCount, 1,
      "Expected Redis.createClient() to be called once"

    assert.property messageServer, 'queue',
      "Expected message server to have a queue property"

    assert.strictEqual clientSpy.callCount, 1,
      "Expected redis.subscribe to be called once"

    assert.isTrue clientSpy.calledWith(serverId),
      "Expected redis.subscribe to be called with #{serverId}"
  finally
    createClientStub.restore()
)

test('.publish publishes to the redis channel for server ID and given type', ->
  serverId = '123'
  type = 'question'
  message = 'an message'

  clientSpy = sinon.spy()
  redisClient = publish: clientSpy
  messageServer = serverId: serverId

  createClientStub = sinon.stub(Redis, 'createClient', -> redisClient)

  try
    MessageServer::publish.call(messageServer, type, message)

    assert.strictEqual clientSpy.callCount, 1,
      "Expected redis.publish to be called once"

    expectedMessage = JSON.stringify({
      type: type,
      message: message
    })

    assert.isTrue clientSpy.calledWith(serverId, expectedMessage),
      "Expected redis.publish to be called with #{serverId}, 'an message'"
  finally
    createClientStub.restore()
)
