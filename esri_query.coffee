request = require('request')
_ = require('underscore')
fs = require('fs')
Esri = require('./indicatorators/esri')

module.exports = (req, res) ->
  serviceName = req.params.serviceName
  featureServer = req.params.featureServer
  indicatorCode = "#{serviceName}:#{featureServer}"

  Esri.fetchDataFromService(serviceName, featureServer, (err, data) ->
    if err?
      console.error err
      return res.send(500, "Couldn't query ESRI Data for #{Esri.makeGetUrl(serviceName, featureServer)}")

    console.log "body: #{data}"

    try
      indicatorData = Esri.indicatorate(indicatorCode, data)
      res.send(200, JSON.stringify(indicatorData))
    catch e
      console.error e.stack
      res.send(500, e.toString())
  )

