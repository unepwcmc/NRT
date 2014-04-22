express = require('express')
http = require('http')
fs = require('fs')

worldBankQuery = require('./controllers/worldbank_query')
cartodbQuery = require('./controllers/cartodb_query')
edeQuery = require('./controllers/ede_query')
indicatorController = require('./controllers/indicators')

checkForIndicatorDefinition = ->
  unless fs.existsSync("#{__dirname}/definitions/indicators.json")
    throw new Error("""
      Couldn't find an indicator definition file in #{__dirname}/definitions/indicators.json
      See #{__dirname}/definitions/examples/ for example config
    """)

checkForIndicatorDefinition()

app = module.exports = express()

app.get "/wb/:countryCode/:indicatorCode", worldBankQuery
app.get "/ede/:countryCode/:variableId", edeQuery
app.get "/indicator/:id/data", indicatorController.query
app.get "/indicators", indicatorController.index
