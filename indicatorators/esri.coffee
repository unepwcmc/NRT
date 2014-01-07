request = require('request')
_ = require('underscore')
fs = require('fs')
SubIndicatorator = require('../lib/subindicatorator')

indicatorDefinitions = JSON.parse(fs.readFileSync('./definitions/esri_indicator_definitions.json', 'UTF8'))

#ESRI_URL = "http://196.218.36.14/ka/rest/services" # K&A Egypt
ESRI_URL = "http://nrtstest.ead.ae/ka/rest/services" # EAD Server
#ESRI_URL = "http://10.20.1.73/ka/rest/services/" # EAD Server (Possibly)
ESRI_QUERY_SUFFIX =
  'where': 'objectid > 0'
  'objectIds': ''
  'time': ''
  'geometry': ''
  'geometryType':'esriGeometryEnvelope'
  'inSR': ''
  'spatialRel':'esriSpatialRelIntersects'
  'relationParam': ''
  'outFields': ''
  'returnGeometry':'false'
  'maxAllowableOffset': ''
  'geometryPrecision': ''
  'outSR': ''
  'gdbVersion': ''
  'returnIdsOnly':'false'
  'returnCountOnly':'false'
  'orderByFields': ''
  'groupByFieldsForStatistics': ''
  'outStatistics': ''
  'returnZ':'false'
  'returnM':'false'
  'f':'pjson'

exports.makeGetUrl = (serviceName, featureServer) ->
  "#{ESRI_URL}/#{serviceName}/FeatureServer/#{featureServer}/query"

validateIndicatorData = (data) ->
  unless data.features?
    throw new Error("ESRI data should ahve a features atributes")

exports.addIndicatorTextToData = (rows, indicatorCode, indicatorDefinition) ->
  outputRows = []
  for row in rows
    value = row[indicatorDefinition.valueField]
    unless value?
      console.log "Row is missing value field '#{indicatorDefinition.valueField}'"
      continue
    row.text = exports._calculateIndicatorText(indicatorCode, value)
    outputRows.push(row)

  return outputRows

exports._calculateIndicatorText = (indicatorCode, value) ->
  value = parseFloat(value)
  ranges = indicatorDefinitions[indicatorCode].ranges

  for range in ranges
    return range.message if value > range.minValue

  return "Error: Value #{value} outside expected range"

exports.getFeatureAttributesFromData = (data) ->
  data = data.features
  return _.map(data, (row) ->
    attributes = {geometry: row.geometry}
    _.extend(attributes, row.attributes)
    attributes
  )
  
# ESRI responses put their attribute data inside an object under an 'attribute'
# key
nestRowsInsideAttributesObject = (rows)->
  nestedRows = []
  for row in rows
    nestedRows.push(attributes: row)

  return nestedRows

exports.indicatorate = (indicatorCode, data) ->
  data = JSON.parse(data)

  validateIndicatorData(data)

  rows = exports.getFeatureAttributesFromData(data)

  indicatorDefinition = indicatorDefinitions[indicatorCode]

  #rows = exports.addIndicatorTextToData(rows, indicatorCode, indicatorDefinition)
  
  unless indicatorDefinition?
    throw new Error("Couldn't find indicator definition for #{indicatorCode}")

  rows = _.sortBy(rows, 'periodStart')

  if indicatorDefinition.reduceField?
    rows = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
      rows,
      indicatorDefinition
    )

  rows = nestRowsInsideAttributesObject(rows)

  return {
    features: rows
  }

exports.fetchDataFromService = (serviceName, featureServer, callback) ->
  console.log exports.makeGetUrl(serviceName, featureServer)

  request.get(
    url: exports.makeGetUrl(serviceName, featureServer)
    qs: ESRI_QUERY_SUFFIX
  , (err, response) ->
    if err?
      callback(err)
    else
      callback(null, response.body)
  )
