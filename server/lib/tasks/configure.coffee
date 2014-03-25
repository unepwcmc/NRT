fs = require 'fs'
path = require 'path'

MessageServer = require('../message_server')

CONFIG_PATH = path.join(__dirname, '..', '..', 'config', 'config_questions.json')

exports.start = ->
  serverId = process.argv[process.argv.length-1]
  console.log "Joining queue #{serverId}"
  messageServer = new MessageServer(serverId: serverId)

  answers = {}

  messageServer.on('answer', (message) ->
    answers[message.id] = message.answer
  )

  messageServer.on('done', ->
    console.log answers
    process.exit(0)
  )

  questions = JSON.parse(fs.readFileSync(CONFIG_PATH))
  messageServer.publish('questions', questions)

exports.start()
