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
      ).fail(callback)

    async.each @theme.indicators, indicatorHasData, (err) =>
      if err?
        deferred.reject(err)
      else
        @theme.indicators = indicatorsWithData
        deferred.resolve()

    deferred.promise

  @populateIndicators: (themes) ->
    Q.nfcall(
      async.each, themes, (theme, callback) ->
        Q.nfcall(
          Theme.getIndicatorsByTheme, theme.id
        ).then( (indicators) ->
          theme.indicators = indicators
          callback()
        ).fail(callback)
    )
