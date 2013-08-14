window.Backbone ||= {}
window.Backbone.Views ||= {}

window.nrtViz ||= {}


class Backbone.Views.BarChartView extends Backbone.View
  #template: Handlebars.templates['bar_chart.hbs']

  initialize: (options) ->
    @barChart = nrtViz.barChart
     xKey: "Year"
     yKey: "Percentage"
    @width = options.width
    @visualisation = options.visualisation
    @barColor = if options.barColor? then options.barColor else "LightSteelBlue"

  render: ->
    @selection = d3.select(@el)
    data = @visualisation.formatDataForChart()
    @selection.data [data]

    @barChart.chart.width @width
    @selection.call @barChart.chart, @barColor

    return @

  onClose: ->
    
