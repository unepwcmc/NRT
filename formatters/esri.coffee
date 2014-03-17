_ = require 'underscore'

module.exports = (data) ->
  formattedData = []

  unless data.features?
    throw new Error(
      "Non-ESRI data passed to ESRI formatter, data is lacking  a 'feature' attribute: '#{JSON.stringify(data)}'"
    )

  for unformattedFeature in data.features
    formattedFeature = {}

    formattedFeature.geometry = unformattedFeature.geometry
    _.extend(formattedFeature, unformattedFeature.attributes)

    formattedData.push(formattedFeature)
    
  return formattedData
