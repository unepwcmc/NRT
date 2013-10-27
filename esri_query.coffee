request = require('request')
_ = require('underscore')
fs = require('fs')

indicatorDefinitions = JSON.parse(fs.readFileSync('./esri_indicator_definitions.json', 'UTF8'))

ESRI_URL = "http://196.218.36.14/ka/rest/services"
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

makeGetUrl = (serviceName, featureServer) ->
  "#{ESRI_URL}/#{serviceName}/FeatureServer/#{featureServer}/query"

validateIndicatorData = (data) ->
  unless data.features?
    throw new Error("ESRI data should ahve a features atributes")

calculateIndicatorText = (indicatorCode, value) ->
  value = parseFloat(value)
  ranges = indicatorDefinitions[indicatorCode].ranges

  for range in ranges
    return range.message if value > range.minValue

  return "Error: Value #{value} outside expected range"

getFeatureAttributesFromData = (data) ->
  data = data.features
  return _.map(data, (row) ->
    row.attributes
  )

averageRows = (rows, indicatorDefinition) ->
  if indicatorDefinition.reduceField?
    valuesByPeriod = {}
    for row in rows
      valuesByPeriod[row.periodStart] || = []
      valuesByPeriod[row.periodStart].push row.value
    
    averagedRows = []
    for periodStart, values of valuesByPeriod
      sum = _.reduce(values, (memo, value) ->
        memo + value
      )

      average = sum/values.length

      averagedRows.push(
        periodStart: periodStart
        value: average
      )
  
    return averagedRows

  else
    return rows
  

indicatorate = (indicatorCode, data) ->
  data = JSON.parse(data)

  validateIndicatorData(data)

  rows = getFeatureAttributesFromData(data)

  outputRows = []

  indicatorDefinition = indicatorDefinitions[indicatorCode]

  valueField = indicatorDefinition.valueField

  rows = averageRows(rows, indicatorDefinition)

  for row in rows
    value = row[valueField]
    continue unless value?
    text = calculateIndicatorText(indicatorCode, value)
    row.text = text
    outputRows.push(attributes: row)

  return {
    features: outputRows
  }

module.exports = (req, res) ->
  serviceName = req.params.serviceName
  featureServer = req.params.featureServer
  indicatorCode = "#{serviceName}:#{featureServer}"

  request.get(
    url: makeGetUrl(serviceName, featureServer)
    qs: ESRI_QUERY_SUFFIX
  , (err, response) ->
    if err?
      console.error err
      res.send(500, "Couldn't query ESRI Data for #{makeGetUrl(serviceName, featureServer)}")

    try
      indicatorData = indicatorate(indicatorCode, response.body)
      res.send(200, JSON.stringify(indicatorData))
    catch e
      console.error e.stack
      res.send(500, e.toString())
  )
