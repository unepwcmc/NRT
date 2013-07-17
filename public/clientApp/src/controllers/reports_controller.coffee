window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ReportsController extends Backbone.Diorama.Controller
  constructor: ->
    @mainRegion = new Backbone.Diorama.ManagedRegion()
    $('body').append(@mainRegion.$el)

    narratives  = new Backbone.Collections.NarrativeCollection()
    narratives.fetch()

    sectionView = new Backbone.Views.SectionView(narratives: narratives)

    @mainRegion.showView(sectionView)
