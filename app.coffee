express = require('express')
http = require('http')
worldBankQuery = require('./controllers/worldbank_query')
esriQuery = require('./controllers/esri_query')
cartodbQuery = require('./controllers/cartodb_query')
edeQuery = require('./controllers/ede_query')

PORT = 3002

exports.start = (callback) ->
  app = express()

  app.get "/wb/:countryCode/:indicatorCode", worldBankQuery
  app.get "/esri/:serviceName/:featureServer", esriQuery
  app.get "/cdb/:username/:tablename/:query", cartodbQuery
  app.get "/ede/:countryCode/:variableId", edeQuery

  server = http.createServer(app).listen PORT, callback
