fs = require('fs')
Q = require('q')
_ = require('underscore')

checkForIndicatorDefinition = ->
  unless fs.existsSync("#{__dirname}/../definitions/indicators.json")
    throw new Error("""
      Couldn't find an indicator definition file in #{__dirname}/definitions/indicators.json
      See #{__dirname}/definitions/examples/ for example config
    """)

checkForIndicatorDefinition()

StandardIndicatorator = require('../indicatorators/standard_indicatorator')
SubIndicatorator = require('../lib/subindicatorator')

GETTERS =
  gdoc: require('../getters/gdoc')
  cartodb: require('../getters/cartodb')
  esri: require('../getters/esri')

FORMATTERS =
  gdoc: require('../formatters/gdoc')
  cartodb: require('../formatters/cartodb')
  esri: require('../formatters/esri')

module.exports = class Indicator
  constructor: (attributes) ->
    _.extend(@, attributes)

  query: ->
    @getData().then( (data) =>
      formattedData = @formatData(data)
      unless @applyRanges is false
        formattedData = StandardIndicatorator.applyRanges(formattedData, @range)

      if @reduceField?
        formattedData = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
          formattedData, {valueField: 'value', reduceField: @reduceField}
        )
        
      return formattedData
    )

  getData: ->
    Getter = GETTERS[@source]
    if Getter?
      getter = new Getter(@)
      getter.fetch()
    else
      throw new Error("No known getter for source '#{@source}'")

  formatData: (data) ->
    formatter = FORMATTERS[@source]
    if formatter?
      formatter(data)
    else
      throw new Error("No known formatter for source '#{@source}'")

  @all: ->
    deferred = Q.defer()

    Q.nsend(
      fs, 'readFile', "#{__dirname}/../definitions/indicators.json"
    ).then( (definitionsJSON) ->
      try
        definitions = JSON.parse(definitionsJSON)
      catch err
        return deferred.reject(new Error("Unable to parse ./definitions/indicators.json"))

      deferred.resolve(definitions)
    ).fail(deferred.reject)

    return deferred.promise

  @find: (id) ->
    deferred = Q.defer()

    Indicator.all().then((definitions) ->

      definitions = _.map(definitions, (definition)->
        definition.id = definition.id + ""
        definition
      )

      definition = _.findWhere(definitions, id: String(id))

      unless definition?
        throw new Error("No indicator definition found for id '#{id}'")

      indicator = new Indicator(definition)

      deferred.resolve(indicator)
    ).fail(
      deferred.reject
    )

    return deferred.promise
