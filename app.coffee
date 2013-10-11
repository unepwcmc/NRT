express = require('express')
http = require('http')
worldBankQuery = require('./worldBank')

PORT = 3001

startApp = ->
  app = express()

  app.get "/wb/:countryCode/:indicatorCode", worldBankQuery

  server = http.createServer(app).listen PORT, (err) ->
    if err
      console.error err
      process.exit 1
    else
      console.log "Express server listening on port " + PORT

startApp()
