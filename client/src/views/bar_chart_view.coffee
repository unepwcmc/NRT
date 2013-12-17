window.Backbone ||= {}
window.Backbone.Views ||= {}

window.nrtViz ||= {}

class Backbone.Views.BarChartView extends Backbone.View
  className: 'section-visualisation bar-chart-view'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change:data', @render)

    @barChart = nrtViz.barChart
     xKey: @visualisation.get('indicator').get('indicatorDefinition').xAxis
     yKey: @visualisation.get('indicator').get('indicatorDefinition').yAxis
    @width = options.width || 250
    @barColor = if options.barColor? then options.barColor else "LightSteelBlue"

    @render()

  render: =>
    if @visualisation.get('data')?
      @renderChart()
    else
      @visualisation.getIndicatorData()

    return @

  renderChart: ->
    @selection = d3.select(@el)
    data = @visualisation.get('data').results
    @selection.data [data]

    @barChart.chart.width @width
    @selection.call @barChart.chart, @barColor

  onClose: ->
    @stopListening()
