fs = require('fs')
Q = require('q')
_ = require('underscore')

GDocGetter = require('../getters/gdoc')
GDocFormatter = require('../formatters/gdoc')

module.exports = class Indicator
  constructor: (attributes) ->
    _.extend(@, attributes)

  query: ->
    new GDocGetter(@).then( (data) ->
      GDocFormatter(data)
    )

  @find: (id) ->
    deferred = Q.defer()

    Q.nsend(
      fs, 'readFile', './definitions/indicators.json'
    ).then( (definitionsJSON) ->

      definitions = JSON.parse(definitionsJSON)
      indicator = new Indicator(
        _.findWhere(definitions, id: id)
      )

      deferred.resolve(indicator)
    ).fail(
      deferred.reject
    )

    return deferred.promise
