window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    report = @createExampleReport()

    reportView = new Backbone.Views.ReportView(report: report)
    $('.report-content').prepend(reportView.el)

    ###
    narratives  = new Backbone.Collections.NarrativeCollection()
    narratives.fetch()
    sectionView = new Backbone.Views.SectionView(narratives: narratives)

    @tmpSectionRegion.showView(sectionView)
    ###

    # First visualization test
    @vizRegion = new Backbone.Diorama.ManagedRegion()
    @vizRegion.$el.attr("class", "viz")
    $('body').append(@vizRegion.$el)
    width = @vizRegion.$el.width()
    barchartView = new Backbone.Views.BarChartView({width: width})
    @vizRegion.showView(barchartView)

  createExampleReport: ->
    new Backbone.Models.Report(
      title: "Test Report"
      brief: "This is for testing"
      sections: [new Backbone.Models.Section(
        title: "Test Section"
        visualisations: [new Backbone.Models.Visualisation()]
      )]
    )
