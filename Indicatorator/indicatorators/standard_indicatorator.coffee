_  = require('underscore')

exports.applyRanges = (data, ranges) ->
  unless data?
    throw new Error("No data to indicatorate")

  outputRows = []

  for row in data
    value = row.value
    continue unless value?
    text = calculateIndicatorText(value, ranges)
    outputRows.push(_.extend(row, text: text))

    if row.subIndicator?
      exports.applyRanges(row.subIndicator, ranges)

  return outputRows

calculateIndicatorText = (value, ranges) ->
  value = parseFloat(value)

  for range in ranges
    return range.message if value >= range.minValue

  return "Error: Value #{value} outside expected range"
