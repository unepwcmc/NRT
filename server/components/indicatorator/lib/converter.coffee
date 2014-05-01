Q = require('q')

CONVERSIONS =
  date:
    epoch: (value) ->
      new Date(value).getTime()
  decimalPercentage:
    integer: (value)->
      value * 100
  epoch:
    date: (value) ->
      new Date(parseInt(value, 10))
    integer: (value) ->
      new Date(parseInt(value, 10)).getFullYear()
  percentage:
    decimal: (value) ->
      parseFloat(value, 10) / 100
    integer: (value) ->
      parseFloat(value, 10)
  text:
    date: (value) ->
      new Date(value.toString())
  year:
    epoch: (value) ->
      new Date(value.toString()).getTime()
    date: (value) ->
      new Date(parseInt(value, 10))


exports.FieldFinder = class FieldFinder
  constructor: (@fields) ->
    @fieldDefinitions = {}

  bySourceName: (sourceName) ->
    if typeof @fieldDefinitions[sourceName] is 'undefined'
      for field in @fields
        if field.source.name is sourceName
          @fieldDefinitions[sourceName] = field

    return @fieldDefinitions[sourceName]


exports.convertSourceValueToInternalValue = (sourceType, internalType, value) ->
  if sourceType is internalType
    return value
  else if CONVERSIONS[sourceType]? and CONVERSIONS[sourceType][internalType]?
    return CONVERSIONS[sourceType][internalType](value)
  else
    throw new Error(
      "Don't know how to convert '#{sourceType}' to '#{internalType}'"
    )

exports.translateRow = (row, fieldFinder) ->
  translatedRow = {}

  for sourceName, value of row
    fieldDefinition = fieldFinder.bySourceName(sourceName)
    if fieldDefinition
      internalName = fieldDefinition.name
      convertedValue = exports.convertSourceValueToInternalValue(
        fieldDefinition.source.type,
        fieldDefinition.type,
        value
      )
      translatedRow[internalName] = convertedValue

  return translatedRow

exports.convertData = (indicatorFields, data) ->
  fieldFinder = new exports.FieldFinder(indicatorFields)
  translationPromises = data.map( (row) ->
    Q.fcall(exports.translateRow, row, fieldFinder)
  )

  return Q.all(translationPromises)