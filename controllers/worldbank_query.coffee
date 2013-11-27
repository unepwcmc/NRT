WorldBank = require('../indicatorators/world_bank')

module.exports = (req, res) ->
  countryCode = req.params.countryCode
  indicatorCode = req.params.indicatorCode

  worldBank = new WorldBank(countryCode, indicatorCode)

  worldBank.fetchDataFromService( (err, data) ->
    if err?
      console.error err
      return res.send(500,
        "Couldn't query World Bank Data for #{worldBank.makeGetUrl()}")

    try
      indicatorData = worldBank.indicatorate()
      res.send(200, JSON.stringify(indicatorData))
    catch e
      console.error e
      console.error e.stack
      res.send(500, e.toString())
  )
