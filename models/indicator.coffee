fs = require('fs')
Q = require('q')

module.exports = class Indicator
  @find: (id) ->
    deferred = Q.defer()

    Q.nsend(
      fs, 'readFile', '../definitions/indicators.json'
    ).then(
      deferred.resolve
    ).fail(
      deferred.reject
    )

    return deferred.promise
