window.Backbone ||= {}
window.Backbone.Views ||= {}

window.nrtViz ||= {}

class Backbone.Views.LineChartView extends Backbone.View
  className: 'line-chart-view'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change:data', @render)
    @lineChart = nrtViz.lineChart
     xKey: "year"
     yKey: "value"
    @width = options.width || 500

  render: =>
    if @visualisation.get('data')?
      @renderChart()
    else
      @visualisation.getIndicatorData()
    @

  renderChart: ->
    @selection = d3.select(@el)
    data = @visualisation.get('data').results
    @selection.data [data]
    @lineChart.chart.width @width
    @selection.call @lineChart.chart, @barColor

  onClose: ->
    @stopListening()
