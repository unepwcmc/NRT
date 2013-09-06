window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.IndicatorCollection extends Backbone.Collection
  model: Backbone.Models.Indicator

  url: "/api/indicators"
