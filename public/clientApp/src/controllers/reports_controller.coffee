window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    @mainRegion = new Backbone.Diorama.ManagedRegion()
    $('#user-section').prepend(@mainRegion.$el)

    narratives  = new Backbone.Collections.NarrativeCollection()
    narratives.fetch()

    sectionView = new Backbone.Views.SectionView(narratives: narratives)

    @vizRegion = new Backbone.Diorama.ManagedRegion()
    @vizRegion.$el.attr("id", "chart")
    $('body').append(@vizRegion.$el)
    barchartView = new Backbone.Views.BarChartView()

    @vizRegion.showView(barchartView)
