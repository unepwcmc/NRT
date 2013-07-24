window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    report = @createExampleReport()

    reportView = new Backbone.Views.ReportView(report: report)
    $('.report-content').prepend(reportView.el)

  createExampleReport: ->
    Backbone.Faker.Reports.create()