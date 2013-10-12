express = require('express')
http = require('http')
worldBankQuery = require('./worldbank_query')
esriQuery = require('./esri_query')

PORT = 3002

startApp = ->
  app = express()

  app.get "/wb/:countryCode/:indicatorCode", worldBankQuery
  app.get "/esri/:serviceName/:featureServer", esriQuery

  server = http.createServer(app).listen PORT, (err) ->
    if err
      console.error err
      process.exit 1
    else
      console.log "Express server listening on port " + PORT

startApp()
