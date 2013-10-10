async = require('async')
Q = require('q')
request = require('request')
_ = require('underscore')

config = 
  indicatorServer: '196.218.36.14/ka'
  defaultQueryParameters:
    'where': 'objectid > 0'
    'objectIds': ''
    'time': ''
    'geometry': ''
    'geometryType':'esriGeometryEnvelope'
    'inSR': ''
    'spatialRel':'esriSpatialRelIntersects'
    'relationParam': ''
    'outFields': ''
    'returnGeometry':'true'
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

module.exports =
  statics: {}
  methods:
    getUpdateUrl: ->
      serviceName = @indicatorDefinition.serviceName
      featureServer = @indicatorDefinition.featureServer

      url = "http://#{config.indicatorServer}/rest/services/#{serviceName}/FeatureServer/#{featureServer}/query"
      return url

    queryIndicatorData: ->
      deferred = Q.defer()
      request
        url: @getUpdateUrl()
        qs: config.standardQuerySuffix
      , (err, response) ->
        if err?
          deferred.reject(err)

        deferred.resolve(response)

      return deferred.promise

    convertResponseToIndicatorData: (responseBody) ->
      convertedData = {
        indicator: @_id
        data: []
      }

      for feature in responseBody.features
        convertedData.data.push _.omit(feature.attributes, 'OBJECTID')

      return convertedData

    validateIndicatorDataFields: (indicatorData) ->
      firstRow = indicatorData.data[0]

      errors = []
      for fields in @indicatorDefinition.fields
        unless firstRow[fields.name]?
          errors.push "Couldn't find '#{fields.name}' attribute in data"

      if errors.length is 0
        return true
      else
        throw new Error(
          errors.join('\n')
        )

