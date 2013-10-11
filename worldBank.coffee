request = require('request')
_ = require('underscore')

WORLD_BANK_URL = "http://api.worldbank.org/countries/"
WORLD_BANK_QUERY_SUFFIX =
  "per_page": 100
  "date": "1960:2013"
  "format": "json"

makeGetUrl = (country, indicator) ->
  "#{WORLD_BANK_URL}/#{country}/indicators/#{indicator}"

indicatorate = (indicatorCode, data) ->
  data = JSON.parse(data)

  unless _.isArray(data)
    throw new Error("World bacnk data shuold be an array")
  unless data.length is 2
    throw new Error("World bank data should have 2 elements")

  rows = data[1]
  outputRows = []

  for row in rows
    outputRows.push(_.extend(row, text: "thing"))

  data[1] = outputRows

  return data

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

    try
      indicatorData = indicatorate(indicatorCode, response.body)
      res.send(200, JSON.stringify(indicatorData))
    catch e
      console.error e.stack
      res.send(500, e.toString())
  )
