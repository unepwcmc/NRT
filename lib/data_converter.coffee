CONVERTERS =
  percentage:
    decimal: (value) ->
      parseFloat(value, 10) / 100
  date:
    epoch: (value) ->
      new Date(value).getTime()

exports.convert = (fromType, toType, value) ->
  throw "DataConverter can't convert null or undefined values" unless value?

  converter = CONVERTERS[fromType]?[toType]
  unless converter?
    throw "DataConverter doesn't know how to convert '#{fromType}' into '#{toType}'"

  return converter(value)
