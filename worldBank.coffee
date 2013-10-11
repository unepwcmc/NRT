request = require('request')

WORLD_BANK_URL = "http://api.worldbank.org/countries/"
WORLD_BANK_QUERY_SUFFIX =
  "per_page": 100
  "date": "1960:2013"
  "format": "json"

makeGetUrl = (country, indicator) ->
  "#{WORLD_BANK_URL}/#{country}/indicators/#{indicator}"

module.exports = (req, res) ->
  countryCode = req.params.countryCode
  indicatorCode = req.params.indicatorCode

  request.get(
    url: makeGetUrl(countryCode, indicatorCode)
    qs: WORLD_BANK_QUERY_SUFFIX
  , (err, response) ->
    if err?
      console.error err
      throw err
      res.send(500, "Couldn't query World Bank Data for #{makeGetUrl(countryCode, indicatorCode)}")

    res.send(200, response.body)
  )
