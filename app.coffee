express = require('express')
http = require('http')
worldBankQuery = require('./worldbank_query')
esriQuery = require('./esri_query')
cartodbQuery = require('./cartodb_query')
edeQuery = require('./ede_query')

PORT = 3002

startApp = ->
  app = express()

  app.get "/wb/:countryCode/:indicatorCode", worldBankQuery
  app.get "/esri/:serviceName/:featureServer", esriQuery
  app.get "/cdb/:username/:tablename/:query", cartodbQuery
  app.get "/ede/:countryCode/:variableId", edeQuery

  server = http.createServer(app).listen PORT, (err) ->
    if err
      console.error err
      process.exit 1
    else
      console.log "Express server listening on port " + PORT

startApp()
