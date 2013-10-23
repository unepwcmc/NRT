window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.IndicatorCollection extends Backbone.Collection
  model: Backbone.Models.Indicator

  url: "/api/indicators"

  groupByType: ->
    grouped = {
      core: []
      external: []
    }

    for indicator in @models
      if indicator.get('type') is 'esri'
        grouped.core.push(indicator)
      else
        grouped.external.push(indicator)

    return grouped
