window.Backbone ||= {}
window.Backbone.Views ||= {}

window.nrtViz ||= {}


class Backbone.Views.BarChartView extends Backbone.View
  #template: Handlebars.templates['bar_chart.hbs']


  initialize: (options) ->
    @barChart = nrtViz.barChart()
    @selection = d3.select(@el)
    console.log @barChart, @selection
    #@render()

  render: ->
    # I think data should go into a backbone model, so render would be tied to
    # model updates.
    data = nrtViz.chartDataParser window.SAMPLE_DATA
    @selection.data [data]
    @selection.call @barChart.chart

    return @

  onClose: ->
    
