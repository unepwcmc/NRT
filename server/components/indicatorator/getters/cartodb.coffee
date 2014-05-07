request = require('request')
Q = require('q')

module.exports = class CartoDBGetter
  constructor: (@indicator) ->

  fetch: ->
    deferred = Q.defer()

    request.get(url: @buildUrl(), (err, response) =>
      if err
        return deferred.reject(err)

      rows = JSON.parse(response.body).rows

      if rows.length <= 1
        deferred.reject(new Error("Unable to find indicator with name '#{@indicator.name}'"))

      deferred.resolve(rows)
    )

    return deferred.promise

  buildUrl: ->
    if !@indicator.indicatorationConfig.cartodb_config?
      throw new Error("Indicator does not define a cartodb_config attribute")
    else if !@indicator.indicatorationConfig.cartodb_config.username?
      throw new Error("Indicator cartodb_config does not define a username attribute")
    else if !@indicator.indicatorationConfig.cartodb_config.table_name?
      throw new Error("Indicator cartodb_config does not define a table_name attribute")

    username = @indicator.indicatorationConfig.cartodb_config.username
    table_name = @indicator.indicatorationConfig.cartodb_config.table_name
    query = """
      SELECT * FROM #{table_name}
      WHERE field_2 = '#{@indicator.shortName}'
      OR field_1 = 'Theme'
    """

    return "http://#{username}.cartodb.com/api/v2/sql?q=#{query}"
