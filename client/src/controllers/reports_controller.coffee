window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: (options) ->
    reportsListView = new Backbone.Views.ReportListView(reports: options.reports)
    $('.reports-container').prepend(reportsListView.el)
