window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.ReportCollection extends Backbone.Collection
  model: Backbone.Models.Report
  url: '/api/report'
