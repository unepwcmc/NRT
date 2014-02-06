fs = require('fs')
Q = require('q')
_ = require('underscore')

StandardIndicatorator = require('../indicatorators/standard_indicatorator')

GETTERS =
  gdoc: require('../getters/gdoc')

FORMATTERS =
  gdoc = require('../formatters/gdoc')

module.exports = class Indicator
  constructor: (attributes) ->
    _.extend(@, attributes)

  query: ->
    @getData().then( (data) =>
      formattedData = @formatData(data)
      StandardIndicatorator.applyRanges(formattedData, @range)
    )

  getData: ->
    getter = GETTERS[@source]
    if getter?
      getter(@)
    else
      throw new Error("No known getter for source '#{@source}'")

  formatData: ->
    formatter = FORMATTERS[@source]
    if formatter?
      formatter(@)
    else
      throw new Error("No known formatter for source '#{@source}'")

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
