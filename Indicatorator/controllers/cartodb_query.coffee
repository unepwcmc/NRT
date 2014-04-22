request = require('request')
_ = require('underscore')
fs = require('fs')

indicatorDefinitions = JSON.parse(fs.readFileSync('./definitions/cartodb_indicator_definitions.json', 'UTF8'))

CARTODB_API_URL = "cartodb.com/api/v2"

makeGetUrl = (username, query) ->
  "http://#{username}.#{CARTODB_API_URL}/sql?q=#{query}"

validateIndicatorData = (data) ->
  unless data.rows?
    throw new Error("Cartodb data should ahve a rows atributes")

calculateIndicatorText = (indicatorCode, value) ->
  value = parseFloat(value)
  ranges = indicatorDefinitions[indicatorCode].ranges

  for range in ranges
    return range.message if value > range.minValue

  return "Error: Value #{value} outside expected range"

indicatorate = (indicatorCode, data) ->
  data = JSON.parse(data)

  validateIndicatorData(data)

  rows = data.rows

  valueField = indicatorDefinitions[indicatorCode].valueField

  value = rows[0].sum
  text = calculateIndicatorText(indicatorCode, value)
  year = new Date().getFullYear()

  return {
    data: [
      value: value
      year: year
      text: text
    ]
  }

module.exports = (req, res) ->
  {username, tablename, query} = req.params
  indicatorCode = "#{username}:#{tablename}"
  url = makeGetUrl(username, query)

  request.get(
    url: url
  , (err, response) ->
    if err?
      console.error err
      throw err
      res.send(500, "Couldn't query data for #{url}")

    try
      indicatorData = indicatorate(indicatorCode, response.body)
      res.send(200, JSON.stringify(indicatorData))
    catch e
      console.error e.stack
      res.send(500, e.toString())
  )

