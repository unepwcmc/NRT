StandardIndicatorator = require('../indicatorators/standard_indicatorator')
SubIndicatorator = require('../lib/subindicatorator')

exports.getData = (indicator) ->
    exports.fetchData().then( (data) =>
      formattedData = exports.formatData(data)
      unless indicator.indicatoration.applyRanges is false
        formattedData = StandardIndicatorator.applyRanges(formattedData, @range)

      if indicator.indicatoration.reduceField?
        formattedData = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
          formattedData, {valueField: 'value', reduceField: @reduceField}
        )

      return formattedData
    )

exports.fetchData = ->
    Getter = GETTERS[@source]
    if Getter?
      getter = new Getter(@)
      getter.fetch()
    else
      throw new Error("No known getter for source '#{@source}'")

exports.formatData = (data) ->
    formatter = FORMATTERS[@source]
    if formatter?
      formatter(data)
    else
      throw new Error("No known formatter for source '#{@source}'")
