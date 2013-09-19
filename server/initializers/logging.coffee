fs = require('fs')
express = require('express')

LOG_DIRECTORY = './logs'

module.exports = (app) ->
  if app.get('env') is 'development'
    app.use express.logger('dev')
  else
    fs.mkdirSync(LOG_DIRECTORY) unless fs.statSync(LOG_DIRECTORY)
    app.use express.logger(
      stream:
        fs.createWriteStream("./#{LOG_DIRECTORY}/#{app.get('env')}.log",
        {flags: 'a'})
    )
