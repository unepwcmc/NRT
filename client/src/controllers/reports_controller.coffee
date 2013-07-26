window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: (reportId)->
    report = @createExampleReport(reportId)

    reportView = new Backbone.Views.ReportView(report: report)
    sectionNavigationView = new Backbone.Views.SectionNavigationView(sections: report.get('sections'))
    $('#report-container').prepend(reportView.el)
    $('#section-navigation-container').prepend(sectionNavigationView.el)



  createExampleReport: (reportId)->
    report = Backbone.Faker.Reports.create()
    report.set('id', reportId)
    report.set('title', report.get('title') + reportId)
