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

CONVERSIONS =
  epoch:
    integer: (value) ->
      new Date(value).getFullYear()


module.exports =
  statics: {}
  methods:
    getUpdateUrl: ->
      if @indicatorDefinition?
        serviceName = @indicatorDefinition.serviceName
        featureServer = @indicatorDefinition.featureServer

      unless serviceName? and featureServer?
        throw "Cannot generate update URL, indicator has no serviceName or featureServer in its indicator definition"

      url = "http://#{config.indicatorServer}/rest/services/#{serviceName}/FeatureServer/#{featureServer}/query"
      return url

    queryIndicatorData: ->
      deferred = Q.defer()

      request.get
        url: @getUpdateUrl()
        qs: config.defaultQueryParameters
        json: true
      , (err, response) ->
        if err?
          deferred.reject(err)

        deferred.resolve(response)

      return deferred.promise

    convertResponseToIndicatorData: (responseBody) ->
      unless _.isArray(responseBody.features)
        throw "Can't convert poorly formed indicator data reponse:\n#{
          JSON.stringify(responseBody)
        }\n expected response to contains 'features' attribute which is an array"

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

    findFieldDefinitionBySourceName: (sourceName) ->
      for field in @indicatorDefinition.fields
        if field.source.name is sourceName
          return field

    convertSourceValueToInternalValue: (sourceName, value) ->
      fieldDefinition = @findFieldDefinitionBySourceName(sourceName)
      sourceType = fieldDefinition.source.type
      internalType = fieldDefinition.type

      if sourceType is internalType
        return value
      else if CONVERSIONS[sourceType]? and CONVERSIONS[sourceType][internalType]?
        return CONVERSIONS[sourceType][internalType](value)
      else
        throw new Error(
          "Don't know how to convert '#{sourceType}' to '#{internalType}' for field '#{sourceName}'"
        )

    translateRow: (row) ->
      translatedRow = {}

      for sourceName, value of row
        fieldDefinition = @findFieldDefinitionBySourceName(sourceName)
        internalName = fieldDefinition.name
        convertedValue = @convertSourceValueToInternalValue(sourceName, value)
        translatedRow[internalName] = convertedValue

      return translatedRow

    convertIndicatorDataFields: (indicatorData) ->
      translatedRows = []

      for row in indicatorData.data
        translatedRows.push @translateRow(row)

      indicatorData.data = translatedRows
      return indicatorData

    replaceIndicatorData: (newIndicatorData) ->
      IndicatorData = require('../models/indicator_data').model
      deferred = Q.defer()

      IndicatorData.findOneAndUpdate(
        {indicator: @},
        newIndicatorData,
        {upsert: true}
        (err, indicatorData) ->
          if err?
            deferred.reject(err)
          else
            deferred.resolve(indicatorData)
      )

      return deferred.promise

    updateIndicatorData: ->
      deferred = Q.defer()
      @queryIndicatorData(
      ).then( (response) =>
        newIndicatorData = @convertResponseToIndicatorData(response.body)
        newIndicatorData = @validateIndicatorDataFields(newIndicatorData)
        newIndicatorData = @convertIndicatorDataFields(newIndicatorData)
        @replaceIndicatorData(newIndicatorData)
      ).then( (indicatorData) ->
        deferred.resolve(indicatorData)
      ).fail( (err) ->
        deferred.reject(err)
      )

      return deferred.promise
