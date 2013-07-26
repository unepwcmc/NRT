window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    report = @createExampleReport()

    reportView = new Backbone.Views.ReportView(report: report)
    sectionNavigationView = new Backbone.Views.SectionNavigationView(sections: report.get('sections'))
    $('#report-container').prepend(reportView.el)
    $('#section-navigation-container').prepend(sectionNavigationView.el)



  createExampleReport: ->
    Backbone.Faker.Reports.create()
