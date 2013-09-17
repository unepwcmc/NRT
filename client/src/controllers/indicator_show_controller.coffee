window.Backbone ||= {}
window.Backbone.Controllers ||= {}


class Backbone.Controllers.IndicatorshowController extends Backbone.Diorama.Controller
  constructor: (indicatorData) ->
    indicator = new Backbone.Models.Indicator indicatorData
    visualisation = new Backbone.Models.Visualisation indicator: indicator
    visualisationView = new Backbone.Views.VisualisationView(
      visualisation: visualisation
    )
    $("#visualisation").html(visualisationView.el)
    visualisationView.render()

    

