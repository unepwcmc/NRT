Q = require('q')
async = require('async')

Theme = require('../../models/theme').model
HeadlineService = require('../services/headline')

module.exports = class ThemePresenter

  @populateIndicatorRecencyStats: (themes) ->
    for theme in themes
      theme.outOfDateIndicatorCount = 0
      for indicator in theme.indicators
        indicator.isUpToDate = HeadlineService.narrativeRecencyTextIsUpToDate(
          indicator.narrativeRecency
        )
        unless indicator.isUpToDate
          theme.outOfDateIndicatorCount++

  @populateIndicators: (themes, filter) ->
    Q.nfcall(
      async.each, themes, (theme, callback) ->
        Q.nfcall(
          Theme.getIndicatorsByTheme, theme.id, filter
        ).then( (indicators) ->
          theme.indicators = indicators
          callback()
        ).fail(callback)
    )
