window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportController extends Backbone.Diorama.Controller
  constructor: ->
    report = @createExampleReport()

    reportView = new Backbone.Views.ReportView(report: report)
    $('#report-container').prepend(reportView.el)

  createExampleReport: ->
    Backbone.Faker.Reports.create()
