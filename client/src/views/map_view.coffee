window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.MapView extends Backbone.View
  template: Handlebars.templates['map.hbs']

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change', @render)

    @barChart = nrtViz.barChart
     xKey: "year"
     yKey: "value"
    @width = options.width || 250
    @barColor = if options.barColor? then options.barColor else "LightSteelBlue"

  render: =>
    if @visualisation.get('data')?
      @$el.html(@template())
    else
      @visualisation.getIndicatorData()

    return @

  onClose: ->
    
