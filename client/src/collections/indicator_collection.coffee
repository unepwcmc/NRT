window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.IndicatorCollection extends Backbone.Collection
  model: Backbone.Models.Indicator

  url: "/api/indicators"

  groupByType: ->
    grouped = {
      primary: []
      secondary: []
    }

    for indicator in @models
      if indicator.get('type') is 'esri'
        grouped.primary.push(indicator)
      else
        grouped.secondary.push(indicator)

    return grouped
