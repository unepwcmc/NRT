Redis = require('redis')

module.exports = class MessageServer
  constructor: (options) ->
    @serverId = options.serverId
    @subscribe()

  subscribe: ->
    @queue = Redis.createClient()
    @queue.subscribe(@serverId)

  publish: (type, message) ->
    # node-redis requires separate connections for subscription and
    # publishing
    publishQueue = Redis.createClient()

    messageJSON = JSON.stringify({
      type: type,
      message: message
    })

    publishQueue.publish(@serverId, messageJSON)

  on: (event, callback) ->
    @queue.on("message", (channel, message) ->
      messageJSON = JSON.parse(message)

      if messageJSON.type is event
        callback(messageJSON)
    )
