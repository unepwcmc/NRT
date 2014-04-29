request = require('request')
Q = require('q')

ESRI_QUERY_PARAMS =
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

module.exports = class EsriGetter
  constructor: (@indicator) ->

  buildUrl: ->
    if !@indicator.indicatorationConfig.esriConfig?
      throw new Error("Indicator does not define a esriConfig attribute")
    else if !@indicator.indicatorationConfig.esriConfig.serviceName?
      throw new Error("Indicator esriConfig does not define a serviceName attribute")
    else if !@indicator.indicatorationConfig.esriConfig.featureServer?
      throw new Error("Indicator esriConfig does not define a featureServer attribute")
    else if !@indicator.indicatorationConfig.esriConfig.serverUrl?
      throw new Error("Indicator esriConfig does not define a serverUrl attribute")

    return "#{
      @indicator.indicatorationConfig.esriConfig.serverUrl
    }/#{
      @indicator.indicatorationConfig.esriConfig.serviceName
    }/FeatureServer/#{
      @indicator.indicatorationConfig.esriConfig.featureServer
    }/query"

  fetch: ->
    deferred = Q.defer()

    request.get({
      url: @buildUrl()
      qs: ESRI_QUERY_PARAMS
    }, (err, response) =>
      if err
        return deferred.reject(err)

      data = JSON.parse(response.body)
      if data.error?
        return deferred.reject(data.error)
      else
        return deferred.resolve(data)
    )

    return deferred.promise

  getQueryParams: ->
    return ESRI_QUERY_PARAMS
