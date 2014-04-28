RangeApplicator = require('../lib/range_applicator')
SubIndicatorator = require('../lib/subindicatorator')

GETTERS =
  gdoc: require('../getters/gdoc')
  cartodb: require('../getters/cartodb')
  esri: require('../getters/esri')
  worldBank: require('../getters/world_bank')

FORMATTERS =
  gdoc: require('../formatters/gdoc')
  cartodb: require('../formatters/cartodb')
  esri: require('../formatters/esri')


exports.getData = (indicator) ->
  exports.fetchData(indicator).then( (data) =>
    formattedData = exports.formatData(indicator.indicatorationConfig.source, data)
    unless indicator.indicatorationConfig.applyRanges is false
      formattedData = RangeApplicator.applyRanges(
        formattedData, indicator.indicatorationConfig.range
      )

    if indicator.indicatorationConfig.reduceField?
      formattedData = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
        formattedData, {valueField: 'value', reduceField: indicator.indicatorationConfig.reduceField}
      )

    return formattedData
  )

exports.fetchData = (indicator) ->
  Getter = GETTERS[indicator.indicatorationConfig.source]
  if Getter?
    getter = new Getter(indicator)
    getter.fetch()
  else
    throw new Error("No known getter for source '#{indicator.indicatorationConfig.source}'")

exports.formatData = (source, data) ->
  formatter = FORMATTERS[source]
  if formatter?
    formatter(data)
  else
    throw new Error("No known formatter for source '#{source}'")
