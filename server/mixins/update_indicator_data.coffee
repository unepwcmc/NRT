async = require('async')
Q = require('q')
request = require('request')
_ = require('underscore')

CONVERSIONS =
  epoch:
    integer: (value) ->
      new Date(parseInt(value, 10)).getFullYear()

    date: (value) ->
      new Date(parseInt(value, 10))

  decimalPercentage:
    integer: (value)->
      value * 100


module.exports =
  statics: {}
  methods:
    convertResponseToIndicatorData: (data) ->
      unless _.isArray(data)
        throw "Can't convert poorly formed indicator data reponse:\n#{
          JSON.stringify(data)
        }\n expected response to be an array"

      return {
        indicator: @_id
        data: data
      }

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

      Indicatorator = require('../components/indicatorator/lib/indicatorator')

      Indicatorator.getData(
        @
      ).then( (data) =>
        newIndicatorData = @convertResponseToIndicatorData(data)
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
