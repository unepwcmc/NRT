window.Nrt ||= {}
window.Nrt.Presenters ||= {}

class Nrt.Presenters.ThemePresenter
  constructor: (@theme) ->

  populateIndicatorCount: (indicators) ->
    indicatorsForTheme = indicators.filterByTheme(@theme)
    @theme.set('indicatorCount', indicatorsForTheme.length)
