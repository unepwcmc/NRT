Ede = require('./indicatorators/ede')

module.exports = (req, res) ->
  countryCode = req.params.countryCode
  variableId = req.params.variableId
  indicatorCode = "#{countryCode}:#{variableId}"

  ede = new Ede(countryCode, variableId)

  ede.fetchDataFromService( (err, data) ->
    if err?
      console.error err
      return res.send(500, "Couldn't query EDE Data for
        #{ede.makeGetUrl()}")

    try
      indicatorData = ede.indicatorate()
      res.send(200, JSON.stringify(indicatorData))
    catch e
      console.error e
      console.error e.stack
      res.send(500, e.toString())
  )

