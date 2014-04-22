request = require('request')

EDE_API_URL = "http://geodev.grid.unep.ch/api"

class Ede
  constructor: (@countryCode, @variableId) ->
    @indicatorCode = "#{@countryCode}:#{@variableId}"

  makeGetUrl: ->
    "#{EDE_API_URL}/countries/#{@countryCode}/variables/#{@variableId}"

  fetchDataFromService: (callback) ->
    request.get(
      url: @makeGetUrl()
    , (err, response) =>
      if err?
        return callback(err)

      try
        data = JSON.parse(response.body)
        callback(null, data)
      catch e
        callback(e)
    )

module.exports = Ede
