TYPE_SOURCE_MAP =
  esri: 'Environment Agency - Abu Dhabi'
  worldBank: 'World Bank Database'

module.exports = class IndicatorPresenter

  constructor: (@indicator) ->

  populateSourceFromType: ->
    @indicator.source = TYPE_SOURCE_MAP[@indicator.type]
