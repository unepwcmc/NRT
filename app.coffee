express = require('express')
http = require('http')

PORT = 3001

startApp = ->
  app = express()

  app.get "/wb/:countryCode/:indicatorCode", (req, res) ->
    countryCode = req.params.countryCode
    indicatorCode = req.params.indicatorCode
    
    return res.send(200, "Working, yeah?")

  server = http.createServer(app).listen PORT, (err) ->
    if err
      console.error err
      process.exit 1
    else
      console.log "Express server listening on port " + PORT

startApp()
