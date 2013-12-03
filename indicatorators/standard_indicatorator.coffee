fs = require('fs')
_  = require('underscore')

exports.applyRanges = (data, ranges) ->
  unless data?
    throw new Error("No data to indicatorate")

  outputRows = []

  for row in data
    value = row.value
    continue unless value?
    text = exports.calculateIndicatorText(value, ranges)
    outputRows.push(_.extend(row, text: text))

  return outputRows

exports.calculateIndicatorText = (value, ranges) ->
  value = parseFloat(value)

  for range in ranges
    return range.message if value > range.minValue

  return "Error: Value #{value} outside expected range"
