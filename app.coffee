express = require('express')
http = require('http')
worldBankQuery = require('./controllers/worldbank_query')
esriQuery = require('./controllers/esri_query')
cartodbQuery = require('./controllers/cartodb_query')

PORT = 3002

startApp = ->
  app = express()

  app.get "/wb/:countryCode/:indicatorCode", worldBankQuery
  app.get "/esri/:serviceName/:featureServer", esriQuery
  app.get "/cdb/:username/:tablename/:query", cartodbQuery

  server = http.createServer(app).listen PORT, (err) ->
    if err
      console.error err
      process.exit 1
    else
      console.log "Express server listening on port " + PORT

startApp()
