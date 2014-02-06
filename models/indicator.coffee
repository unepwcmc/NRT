fs = require('fs')
Q = require('q')
_ = require('underscore')

GDocFormatter = require('../formatters/gdoc')
StandardIndicatorator = require('../indicatorators/standard_indicatorator')

GETTERS =
  gdoc: require('../getters/gdoc')

module.exports = class Indicator
  constructor: (attributes) ->
    _.extend(@, attributes)

  query: ->
    @getData().then( (data) =>
      @formatData(data)
    )
    #new GDocGetter(@).then( (data) =>
      #formattedData = GDocFormatter(data)
      #StandardIndicatorator.applyRanges(formattedData, @range)
    #)

  getData: ->
    GETTERS[@source](@)

  formatData: ->

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
