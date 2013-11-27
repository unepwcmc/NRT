Ede = require('../retrievers/ede')
StandardIndicatorator = require('../indicatorators/standard_indicatorator')

module.exports = (req, res) ->
  countryCode = req.params.countryCode
  variableId = req.params.variableId

  ede = new Ede(countryCode, variableId)

  ede.fetchDataFromService( (err, data) ->
    if err?
      console.error err
      return res.send(500, "Couldn't query EDE Data for
        #{ede.makeGetUrl()}")

    try
      indicatorator = new StandardIndicatorator('ede', ede.indicatorCode)
      indicatorData = indicatorator.indicatorate(data)
      res.send(200, JSON.stringify(indicatorData))
    catch e
      console.error e
      console.error e.stack
      res.send(500, e.toString())
  )

