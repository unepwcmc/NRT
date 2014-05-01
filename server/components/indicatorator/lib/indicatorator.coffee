Converter        = require('../lib/converter')
RangeApplicator  = require('../lib/range_applicator')
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
  worldBank: require('../formatters/world_bank')


exports.getData = (indicator) ->
  indicatorationConfig = indicator.indicatorationConfig
  indicatorDefinition = indicator.indicatorDefinition

  exports.fetchData(
    indicator
  ).then( (rawData) =>
    exports.formatData(indicatorationConfig.source, rawData)
  ).then( (formattedData) =>
    if indicatorationConfig.applyRanges is false
      formattedData
    else
      applyRanges(indicatorationConfig.range, formattedData)
  ).then( (formattedData) =>
    if indicatorationConfig.reduceField?
      reduceFields(indicatorationConfig.reduceField, formattedData)
    else
      formattedData
  ).then( (formattedData) =>
    exports.convertData(indicatorDefinition.fields, formattedData)
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

exports.convertData = (indicatorFields, data) ->
  Converter.convertData(indicatorFields, data)

applyRanges = (ranges, data) ->
  RangeApplicator.applyRanges(data, ranges)

reduceFields = (reduceField, data) ->
  return SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
    data, {valueField: 'value', reduceField: reduceField}
  )
