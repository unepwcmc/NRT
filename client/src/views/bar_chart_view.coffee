window.Backbone ||= {}
window.Backbone.Views ||= {}

window.nrtViz ||= {}

class Backbone.Views.BarChartView extends Backbone.View
  #template: Handlebars.templates['bar_chart.hbs']
  className: 'bar-chart-view'

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
      @selection = d3.select(@el)
      data = @visualisation.get('data').results
      @selection.data [data]

      @barChart.chart.width @width
      @selection.call @barChart.chart, @barColor
    else
      @visualisation.getIndicatorData()

    return @

  onClose: ->
    
