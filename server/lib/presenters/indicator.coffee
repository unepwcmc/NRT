TYPE_SOURCE_MAP =
  esri: 'Environment Agency - Abu Dhabi'
  worldBank: 'World Bank Database'

module.exports = class IndicatorPresenter

  constructor: (@indicator) ->

  populateSourceFromType: ->
    @indicator.source = TYPE_SOURCE_MAP[@indicator.type]

  populateHeadlineRangesFromHeadlines: (headlines) ->
    @indicator.headlineRanges = {}
    xAxis = @indicator.indicatorDefinition?.xAxis

    if xAxis?
      @indicator.headlineRanges =
        oldest: headlines[0][xAxis]
        newest: headlines[headlines.length - 1][xAxis]
