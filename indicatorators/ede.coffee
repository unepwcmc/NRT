request = require('request')
fs      = require('fs')

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

    console.log @data

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
