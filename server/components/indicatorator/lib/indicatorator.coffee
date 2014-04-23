module.exports.getData = ->
  getData().then( (data) =>
    formattedData = formatData(data)
    unless @applyRanges is false
      formattedData = StandardIndicatorator.applyRanges(formattedData, @range)

    if @reduceField?
      formattedData = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
        formattedData, {valueField: 'value', reduceField: @reduceField}
      )

    return formattedData
  )

getData = ->
  Getter = GETTERS[@source]
  if Getter?
    getter = new Getter(@)
    getter.fetch()
  else
    throw new Error("No known getter for source '#{@source}'")

formatData = (data) ->
  formatter = FORMATTERS[@source]
  if formatter?
    formatter(data)
  else
    throw new Error("No known formatter for source '#{@source}'")
