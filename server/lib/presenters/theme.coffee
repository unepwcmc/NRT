Q = require('q')
async = require('async')

Theme = require('../../models/theme').model
HeadlineService = require('../services/headline')

module.exports = class ThemePresenter
  constructor: (@theme) ->

  @populateIndicatorRecencyStats: (themes) ->
    for theme in themes
      theme.outOfDateIndicatorCount = 0
      for indicator in theme.indicators
        indicator.isUpToDate = HeadlineService.narrativeRecencyTextIsUpToDate(
          indicator.narrativeRecency
        )
        unless indicator.isUpToDate
          theme.outOfDateIndicatorCount++

  filterIndicatorsWithData: ->
    deferred = Q.defer()

    indicatorsWithData = []

    indicatorHasData = (indicator, callback) ->
      indicator.hasData().then( (hasData) ->
        if hasData
          indicatorsWithData.push(indicator)

        callback(null)
      ).catch(callback)

    if @theme.indicators?
      async.each @theme.indicators, indicatorHasData, (err) =>
        if err?
          deferred.reject(err)
        else
          @theme.indicators = indicatorsWithData
          deferred.resolve()
    else
      deferred.reject(new Error('filterIndicatorsWithData called on a theme without an indicator attribute'))

    deferred.promise

  @populateIndicators: (themes, filter) ->
    Q.nfcall(
      async.each, themes, (theme, callback) ->
        Q.nfcall(
          Theme.getIndicatorsByTheme, theme.id, filter
        ).then( (indicators) ->
          theme.indicators = indicators
          callback()
        ).catch(callback)
    )
