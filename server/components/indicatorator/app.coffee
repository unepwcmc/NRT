express = require('express')
http = require('http')
fs = require('fs')

indicatorController = require('./controllers/indicators')

checkForIndicatorDefinition = ->
  unless fs.existsSync("#{__dirname}/definitions/indicators.json")
    throw new Error("""
      Couldn't find an indicator definition file in #{__dirname}/definitions/indicators.json
      See #{__dirname}/definitions/examples/ for example config
    """)

checkForIndicatorDefinition()

app = module.exports = express()

app.get "/indicator/:id/data", indicatorController.query
app.get "/indicators", indicatorController.index
