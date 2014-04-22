request = require('request')
fs      = require('fs')
_       = require('underscore')

WORLD_BANK_URL = "http://api.worldbank.org/countries/"
WORLD_BANK_QUERY_SUFFIX =
  "per_page": 100
  "date": "1960:2013"
  "format": "json"

class WorldBank
  constructor: (@countryCode, @indicatorCode) ->
    @indicatorDefinition = JSON.parse(
      fs.readFileSync('./definitions/worldbank_indicator_definitions.json', 'UTF8')
    )[@indicatorCode]

  indicatorate: ->
    unless @data?
      throw "You must call fetchDataFromService before indicatorating"

    unless @dataValid
      throw "World Bank data must be an array of length 2"

    rows = @data[1]
    outputRows = []

    valueField = @indicatorDefinition.valueField

    for row in rows
      value = row[valueField]
      continue unless value?
      text = @calculateIndicatorText(value)
      outputRows.push(_.extend(row, text: text))

    @data[1] = _.sortBy(outputRows, 'date')

    return @data

  calculateIndicatorText: (value) ->
    value = parseFloat(value)
    ranges = @indicatorDefinition.ranges

    for range in ranges
      return range.message if value > range.minValue

    return "Error: Value #{value} outside expected range"

  dataValid: ->
    return _.isArray(@data) and @data.length is 2

  makeGetUrl: ->
    "#{WORLD_BANK_URL}/#{@countryCode}/indicators/#{@indicatorCode}"

  fetchDataFromService: (callback) ->
    request.get(
      url: @makeGetUrl()
      qs: WORLD_BANK_QUERY_SUFFIX
    , (err, response) =>
      if err?
        return callback(err)

      @data = JSON.parse(response.body)
      callback(null, response.body)
    )

module.exports = WorldBank
