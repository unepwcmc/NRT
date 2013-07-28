window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportPresentationController extends Backbone.Diorama.Controller
  constructor: (reportData) ->
    report = new Backbone.Models.Report(reportData)

    reportPresentationView = new Backbone.Views.ReportPresentationView(report: report)
    $('#report-presentation-container').prepend(reportPresentationView.el)
