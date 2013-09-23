fs = require('fs')
express = require('express')

LOG_DIRECTORY = './logs'

module.exports = (app) ->
  if app.get('env') is not 'development'
    fs.mkdirSync(LOG_DIRECTORY) unless fs.statSync(LOG_DIRECTORY)
    app.use express.logger(
      stream:
        fs.createWriteStream("./#{LOG_DIRECTORY}/#{app.get('env')}.log",
        {flags: 'a'})
    )
  else
    app.use express.logger("dev") unless app.get('env') is "test"
