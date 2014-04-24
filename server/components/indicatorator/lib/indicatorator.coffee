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


exports.getData = (indicator) ->
  exports.fetchData(indicator).then( (data) =>
    formattedData = exports.formatData(indicator.indicatoration.source, data)
    unless indicator.indicatoration.applyRanges is false
      formattedData = StandardIndicatorator.applyRanges(
        formattedData, indicator.indicatoration.range
      )

    if indicator.indicatoration.reduceField?
      formattedData = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
        formattedData, {valueField: 'value', reduceField: indicator.indicatoration.reduceField}
      )

    return formattedData
  )

exports.fetchData = (indicator) ->
  Getter = GETTERS[indicator.indicatoration.source]
  if Getter?
    getter = new Getter(indicator)
    getter.fetch()
  else
    throw new Error("No known getter for source '#{indicator.indicatoration.source}'")

exports.formatData = (source, data) ->
  formatter = FORMATTERS[source]
  if formatter?
    formatter(data)
  else
    throw new Error("No known formatter for source '#{source}'")
