request = require('request')
fs      = require('fs')
_       = require('underscore')

EDE_API_URL = "http://geodev.grid.unep.ch/api"

class Ede
  constructor: (@countryCode, @variableId) ->
    indicatorCode = "#{@countryCode}:#{@variableId}"
    @indicatorDefinition = JSON.parse(
      fs.readFileSync('./ede_indicator_definitions.json', 'UTF8')
    )[indicatorCode]

  indicatorate: ->
    unless @data?
      throw "You must call fetchDataFromService before indicatorating"

    valueField = @indicatorDefinition.valueField

    outputRows = []

    for row in @data
      value = row[valueField]
      continue unless value?
      text = @calculateIndicatorText(value)
      outputRows.push(_.extend(row, text: text))

    return @data

  calculateIndicatorText: (value) ->
    value = parseFloat(value)
    ranges = @indicatorDefinition.ranges

    for range in ranges
      return range.message if value > range.minValue

    return "Error: Value #{value} outside expected range"

  makeGetUrl: ->
    "#{EDE_API_URL}/countries/#{@countryCode}/variables/#{@variableId}"

  fetchDataFromService: (callback) ->
    request.get(
      url: @makeGetUrl()
    , (err, response) =>
      if err?
        return callback(err)

      try
        @data = JSON.parse(response.body)
        callback(null, response.body)
      catch e
        callback(e)
    )

module.exports = Ede
