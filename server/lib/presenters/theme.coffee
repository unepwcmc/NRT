HeadlineService = require('../services/headline')

module.exports = class ThemePresenter

  @populateIndicatorRecencyStats: (themes) ->
    for theme in themes
      theme.outOfDateIndicatorCount = 0
      for indicator in theme.indicators
        indicator.isUpToDate = HeadlineService.narrativeRecencyTextIsUpToDate(
          indicator.narrativeRecency
        )
        if indicator.isUpToDate
          theme.outOfDateIndicatorCount++

