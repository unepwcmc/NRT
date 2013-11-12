async = require('async')
Q = require('q')
request = require('request')
_ = require('underscore')

CONFIG =
  esri:
    indicatorServer: 'localhost:3002/esri'
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

  worldBank:
    defaultQueryParameters:
      "per_page": 100
      "date": "1960:2013"
      "format": "json"
  cartodb:
    defaultQueryParameters: {}

CONVERSIONS =
  epoch:
    integer: (value) ->
      new Date(parseInt(value, 10)).getFullYear()

    date: (value) ->
      new Date(parseInt(value, 10))
      
  decimalPercentage:
    integer: (value)->
      value * 100

URL_BUILDERS =
  esri: ->
    if @indicatorDefinition?
      serviceName = @indicatorDefinition.serviceName
      featureServer = @indicatorDefinition.featureServer

    unless serviceName? and featureServer?
      throw "Cannot generate update URL, esri indicator has no serviceName or featureServer in its indicator definition"

    url = "http://#{CONFIG[@type].indicatorServer}/#{serviceName}/#{featureServer}"
    return url

  worldBank: ->

    if @indicatorDefinition?
      apiUrl = @indicatorDefinition.apiUrl
      apiIndicatorName = @indicatorDefinition.apiIndicatorName

    unless apiUrl? and apiIndicatorName?
      throw "Cannot generate update URL, indicator has no apiUrl or apiIndicatorName in its indicator definition"

    url = "#{apiUrl}/#{apiIndicatorName}"
    return url

  cartodb: ->
    if @indicatorDefinition?
      apiUrl = @indicatorDefinition.apiUrl
      cartodb_user = @indicatorDefinition.cartodb_user
      cartodb_tablename = @indicatorDefinition.cartodb_tablename
      query = encodeURIComponent(@indicatorDefinition.query)

    unless cartodb_user? and query?
      throw "Cannot generate update URL, indicator of type 'cartodb' has no cartodb_user or query in its indicator definition"

    url = "#{apiUrl}/cdb/#{cartodb_user}/#{cartodb_tablename}/#{query}"
    return url


SOURCE_DATA_PARSERS =
  esri: (responseBody) ->
    unless _.isArray(responseBody.features)
      throw "Can't convert poorly formed indicator data reponse:\n#{
        JSON.stringify(responseBody)
      }\n expected response to contains 'features' attribute which is an array"

    convertedData = {
      indicator: @_id
      data: []
    }

    for feature in responseBody.features
      featureObject = {geometry: feature.geometry}
      attributes = _.omit(feature.attributes, 'OBJECTID')
      _.extend(featureObject, attributes)

      convertedData.data.push featureObject

    return convertedData

  worldBank: (responseBody) ->
    unless _.isArray(responseBody) and responseBody.length is 2
      throw "Can't convert poorly formed indicator data reponse:\n#{
        JSON.stringify(responseBody)
      }\n expected response to be a world bank api response;#{
      } an array with a data array as the second element"

    return convertedData = {
      indicator: @_id
      data: responseBody[1]
    }

  cartodb: (responseBody) ->
    unless responseBody.data?
      throw "Can't convert poorly formed indicator data reponse:\n#{
        JSON.stringify(responseBody)
      }\n expected response to be a cartodb api response"

    return convertedData = {
      indicator: @_id
      data: responseBody.data
    }

module.exports =
  statics: {}
  methods:
    getUpdateUrl: ->
      urlBuilder = URL_BUILDERS[@type]
      if urlBuilder?
        return urlBuilder.call(@)
      else
        throw new Error("Couldn't find a url builder for indicator.type: '#{@type}'")

    queryIndicatorData: ->
      deferred = Q.defer()

      request.get
        url: @getUpdateUrl()
        qs: CONFIG[@type].defaultQueryParameters
        json: true
      , (err, response) ->
        if err?
          deferred.reject(err)

        deferred.resolve(response)

      return deferred.promise

    convertResponseToIndicatorData: (responseBody) ->
      sourceDataParser = SOURCE_DATA_PARSERS[@type]
      if sourceDataParser?
        return sourceDataParser.call(@, responseBody)
      else
        throw new Error("Couldn't find a data parser for indicator.type: '#{@type}'")

    validateIndicatorDataFields: (indicatorData) ->
      firstRow = indicatorData.data[0]

      errorMsg = "Error validating indicator data for indicator '#{@title}'\n* "
      errors = []

      for field in @indicatorDefinition.fields
        unless field.source?
          errors.push "Indicator field definition doesn't include a source attribute: #{
            JSON.stringify(field)
          }"
          continue
        unless firstRow.hasOwnProperty(field.source.name)
          errors.push "Couldn't find source attribute '#{field.source.name}' in data"

      if errors.length is 0
        return true
      else
        errorMsg += errors.join('\n* ')
        errorMsg += "\n Data: #{JSON.stringify(indicatorData.data)}"
        throw new Error(errorMsg)

    findFieldDefinitionBySourceName: (sourceName) ->
      for field in @indicatorDefinition.fields
        if field.source.name is sourceName
          return field

      return false

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
        if fieldDefinition
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
        if @validateIndicatorDataFields(newIndicatorData)
          newIndicatorData = @convertIndicatorDataFields(newIndicatorData)
          return @replaceIndicatorData(newIndicatorData)
        else
          throw new Error("Validation of indicator data fields failed")
      ).then( (indicatorData) ->
        deferred.resolve(indicatorData)
      ).fail( (err) ->
        deferred.reject(err)
      )

      return deferred.promise
