window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsPresentationController extends Backbone.Diorama.Controller
  constructor: ->
    report = @createExampleReport()

    reportPresentationView = new Backbone.Views.ReportPresentationView(report: report)
    $('#report-presentation-container').prepend(reportPresentationView.el)

  createExampleReport: ->
    Backbone.Faker.Reports.create()
