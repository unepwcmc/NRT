express = require('express')
http = require('http')
fs = require('fs')

worldBankQuery = require('./controllers/worldbank_query')
cartodbQuery = require('./controllers/cartodb_query')
edeQuery = require('./controllers/ede_query')
indicatorData = require('./controllers/indicators')

exports.start = (port, callback) ->
  checkForIndicatorDefinition()

  app = express()

  app.get "/wb/:countryCode/:indicatorCode", worldBankQuery
  app.get "/ede/:countryCode/:variableId", edeQuery
  app.get "/indicator/:id/data", indicatorData.query

  server = http.createServer(app).listen port, (err) ->
    callback err, server

checkForIndicatorDefinition = ->
  unless fs.existsSync('./definitions/indicators.json')
    throw new Error(
      """
        Couldn't find an indicator definition file in ./definitions/indicators.json
        See ./definitions/examples/ for example config
      """
    )
