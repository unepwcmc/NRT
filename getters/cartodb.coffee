request = require('request')
Q = require('q')

module.exports = class CartoDBGetter
  constructor: (indicator) ->
    @indicator = indicator

  fetch: ->
    deferred = Q.defer()

    request.get(url: @buildUrl(), (err, response) ->
      if err
        return deferred.reject(err)

      deferred.resolve(response.body)
    )

    return deferred.promise

  buildUrl: ->
    if !@indicator.cartodb_config?
      throw new Error("Indicator does not define a cartodb_config attribute")
    else if !@indicator.cartodb_config.username?
      throw new Error("Indicator cartodb_config does not define a username attribute")
    else if !@indicator.cartodb_config.table_name?
      throw new Error("Indicator cartodb_config does not define a table_name attribute")

    username = @indicator.cartodb_config.username
    table_name = @indicator.cartodb_config.table_name
    query = """
      SELECT * FROM #{table_name}
      WHERE field_2 = '#{@indicator.name}'
      OR field_1 = 'Theme'
    """

    return "http://#{username}.cartodb.com/api/v2/sql?q=#{query}"
