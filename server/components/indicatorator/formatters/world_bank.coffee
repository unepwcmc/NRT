_ = require 'underscore'

module.exports = (data) ->
  formattedData = []
  for unformattedDataPoint in data[1]
    formattedDataPoint = {}

    formattedDataPoint = {
      value: unformattedDataPoint.value
      date: unformattedDataPoint.date
    }

    formattedData.push(formattedDataPoint)
    
  return formattedData
