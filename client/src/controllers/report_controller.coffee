window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportController extends Backbone.Diorama.Controller
  constructor: (reportData)->
    report = new Backbone.Models.Report(reportData)

    reportView = new Backbone.Views.ReportView(report: report)
    $('#report-container').prepend(reportView.el)

  createExampleReport: (reportId)->
    report = Backbone.Faker.Reports.create()
    report.set('id', reportId)
    report.set('title', report.get('title') + reportId)
