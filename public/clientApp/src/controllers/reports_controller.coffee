window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    @mainRegion = new Backbone.Diorama.ManagedRegion()
    $('#user-section').prepend(@mainRegion.$el)

    narratives  = new Backbone.Collections.NarrativeCollection()
    narratives.fetch()

    sectionView = new Backbone.Views.SectionView(narratives: narratives)

    # First visualization test
    @vizRegion = new Backbone.Diorama.ManagedRegion()
    @vizRegion.$el.attr("class", "viz")
    $('body').append(@vizRegion.$el)
    width = @vizRegion.$el.width()
    barchartView = new Backbone.Views.BarChartView({width: width})
    @vizRegion.showView(barchartView)
