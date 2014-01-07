window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.IndicatorCollection extends Backbone.Collection
  model: Backbone.Models.Indicator

  initialize: (models, options) ->
    @withData = true if options? and options.withData?

  url: ->
    url = "/api/indicators"
    if @withData? and @withData
      url += "?withData=true"
    url

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
