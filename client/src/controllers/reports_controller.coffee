window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    report = @createExampleReport()

    reportView = new Backbone.Views.ReportView(report: report)
    $('#report-container').prepend(reportView.el)

    ###
    narratives  = new Backbone.Collections.NarrativeCollection()
    narratives.fetch()
    sectionView = new Backbone.Views.SectionView(narratives: narratives)

    @tmpSectionRegion.showView(sectionView)
    ###

  createExampleReport: ->
    Backbone.Faker.Reports.create()
