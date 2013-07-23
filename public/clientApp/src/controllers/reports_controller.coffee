window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    report = new Backbone.Models.Report(
      title: "Test Report"
      overview: "This is for testing"
    )

    reportView = new Backbone.Views.ReportView(report: report)
    $('.report-content').prepend(reportView.el)

    @tmpSectionRegion = new Backbone.Diorama.ManagedRegion()
    $('#user-section').prepend(@tmpSectionRegion.$el)

    narratives  = new Backbone.Collections.NarrativeCollection()
    narratives.fetch()

    sectionView = new Backbone.Views.SectionView(narratives: narratives)

    @tmpSectionRegion.showView(sectionView)
