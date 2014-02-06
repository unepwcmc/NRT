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
