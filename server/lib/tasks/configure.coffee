fs = require 'fs'
path = require 'path'

MessageServer = require('../message_server')

CONFIG_PATH = path.join(__dirname, '..', '..', 'config', 'config_questions.json')

exports.start = ->
  [..., serverId] = process.ARGV
  messageServer = new MessageServer(id: serverId)

  messageServer.on('answer', ->)
  messageServer.on('done', ->)

  questions = fs.readFileSync(CONFIG_PATH)
  messageServer.publish(questions)
