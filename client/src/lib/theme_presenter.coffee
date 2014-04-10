window.Nrt ||= {}
window.Nrt.Presenters ||= {}

class Nrt.Presenters.ThemePresenter
  constructor: (@theme) ->

  populateIndicatorCount: (indicators) ->
    return unless indicators?

    indicatorsForTheme = indicators.filterByTheme(@theme)

    indicatorCount = indicatorsForTheme.length
    indicatorCount = '-' if indicatorCount is 0

    @theme.set('indicatorCount', indicatorCount)
