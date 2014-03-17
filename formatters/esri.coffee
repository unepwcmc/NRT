_ = require 'underscore'

module.exports = (data) ->
  formattedData = []

  for unformattedFeature in data.features
    formattedFeature = {}

    formattedFeature.geometry = unformattedFeature.geometry
    _.extend(formattedFeature, unformattedFeature.attributes)

    formattedData.push(formattedFeature)
    
  return formattedData
