_ = require 'underscore'

### Sub indicator functions ###

calculateMode = (values) ->
  counts = {}
  for value in values
    counts[value] ||= 0
    counts[value]++

  mode = null
  for value, count of counts
    if !mode? or counts[mode.value] < count
      mode =
        value: value
        count: count

  return mode

exports.calculateAverageIndicator = (subIndicators, indicatorDefinition) ->
  texts = _.map(subIndicators, (value) ->
    value.text
  )

  mode = calculateMode(texts)

  averageIndicator = {text: mode.value}
  averageIndicator[indicatorDefinition.valueField] = "#{mode.count} of #{subIndicators.length}"

  return averageIndicator

exports.groupSubIndicatorsByPeriod = (subIndicators) ->
  groups = {}
  for row in subIndicators
    groups[row.periodStart] || = []
    groups[row.periodStart].push row
  return groups

exports.groupSubIndicatorsUnderAverageIndicators = (subIndicators, indicatorDefinition) ->
  groupedRows = exports.groupSubIndicatorsByPeriod(subIndicators)

  averagedRows = []
  for periodStart, subIndicators of groupedRows
    averageIndicator = exports.calculateAverageIndicator(subIndicators, indicatorDefinition)
    averageIndicator[indicatorDefinition.reduceField] = subIndicators
    averageIndicator.periodStart = periodStart

    averagedRows.push(averageIndicator)

  return averagedRows
