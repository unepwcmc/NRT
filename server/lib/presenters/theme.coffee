Promise = require('bluebird')
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
    Promise.all(
      Promise.map(themes, (theme) -> theme.populateIndicators(filter))
    )
