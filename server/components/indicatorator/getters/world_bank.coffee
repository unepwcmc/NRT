request = require('request')
Q = require('q')

WORLD_BANK_URL = "http://api.worldbank.org/countries"
WORLD_BANK_QUERY_SUFFIX =
    "per_page": 100
    "format": "json"

module.exports = class WorldBankGetter
  constructor: (@indicator) ->
    @validateFields()

  validateFields: ->
    if !@indicator.indicatorationConfig.worldBankConfig?
      throw new Error("Indicator does not define a worldBankConfig attribute")
    else if !@indicator.indicatorationConfig.worldBankConfig.countryCode?
      throw new Error("Indicator worldBankConfig does not define a countryCode attribute")
    else if !@indicator.indicatorationConfig.worldBankConfig.indicatorCode?
      throw new Error("Indicator worldBankConfig does not define a indicatorCode attribute")

  buildUrl: ->
    return "#{
      WORLD_BANK_URL
    }/#{
      @indicator.indicatorationConfig.worldBankConfig.countryCode
    }/indicators/#{
      @indicator.indicatorationConfig.worldBankConfig.indicatorCode
    }"

  fetch: ->
    deferred = Q.defer()
    request.get(
      url: @buildUrl()
      qs: WORLD_BANK_QUERY_SUFFIX
    , (err, response) =>
      if err?
        return deferred.reject(err)

      data = JSON.parse(response.body)
      return deferred.resolve(data)
    )

    return deferred.promise
