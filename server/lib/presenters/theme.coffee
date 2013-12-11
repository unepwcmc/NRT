Q = require('q')
async = require('async')

Theme = require('../../models/theme')
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

  @populateIndicators: (themes) ->
    Q.nfcall(
      async.each, themes, (theme, callback) ->
        Q.nsend(
          Theme, 'getIndicatorsByTheme', theme.id
        ).then( (indicators) ->
          theme.indicators = indicators
          callback()
        ).fail(callback)
    ).then( ->
      callback null, themes
    ).fail( (err) ->
      callback err
    )
