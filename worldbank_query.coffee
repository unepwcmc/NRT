request = require('request')
_ = require('underscore')
fs = require('fs')

indicatorDefinitions = JSON.parse(fs.readFileSync('./worldbank_indicator_definitions.json', 'UTF8'))

WORLD_BANK_URL = "http://api.worldbank.org/countries/"
WORLD_BANK_QUERY_SUFFIX =
  "per_page": 100
  "date": "1960:2013"
  "format": "json"

makeGetUrl = (country, indicator) ->
  "#{WORLD_BANK_URL}/#{country}/indicators/#{indicator}"

validateIndicatorData = (data) ->
  unless _.isArray(data)
    throw new Error("World bacnk data shuold be an array")
  unless data.length is 2
    throw new Error("World bank data should have 2 elements")

calculateIndicatorText = (indicatorCode, value) ->
  value = parseFloat(value)
  ranges = indicatorDefinitions[indicatorCode].ranges

  for range in ranges
    return range.message if value > range.minValue

  return "Error: Value #{value} outside expected range"

indicatorate = (indicatorCode, data) ->
  data = JSON.parse(data)

  validateIndicatorData(data)

  rows = data[1]
  outputRows = []

  valueField = indicatorDefinitions[indicatorCode].valueField

  for row in rows
    value = row[valueField]
    continue unless value?
    text = calculateIndicatorText(indicatorCode, value)
    outputRows.push(_.extend(row, text: text))

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
