CONVERTERS =
  percentage:
    decimal: (value) ->
      parseFloat(value, 10) / 100
  date:
    epoch: (value) ->
      new Date(value).getTime()
  year:
    epoch: (value) ->
      new Date(value.toString()).getTime()

exports.convert = (fromType, toType, value) ->
  throw new Error("DataConverter can't convert null or undefined values") unless value?

  converter = CONVERTERS[fromType]?[toType]
  unless converter?
    throw new Error("DataConverter doesn't know how to convert '#{fromType}' into '#{toType}'")

  return converter(value)
