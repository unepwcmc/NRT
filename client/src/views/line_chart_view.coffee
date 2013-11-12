window.Backbone ||= {}
window.Backbone.Views ||= {}

COLOR_RANGE = [
  "#4d839a"
  "#406c80"
  "#cfdfe6"
  "#3094bf"
  "#5c70b5"
  "#414f80"
  "#cfd4e6"
  "#3252bf"
  "#4e9c81"
  "#408069"
  "#cfe6dd"
  "#30bf8d"
  "#e6a873"
  "#805e40"
  "#e6d9cf"
  "#bf7330"
]

class Backbone.Views.LineChartView extends Backbone.View
  template: Handlebars.templates['line_chart.hbs']
  className: 'editable-visualisation'

  initialize: (options={}) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change:data', @render)

    @render()

  render: ->
    if @visualisation.get('data')?
      @$el.html(@template())
      @renderChart()
    else
      @visualisation.getIndicatorData()

    return @

  generateColourRange: ->
    colours = []

    for hex in COLOR_RANGE
      colours.push {
        fillColor: "rgba(0,0,0,0)"
        strokeColor: hex
        pointColor: hex
        pointStrokeColor: "#fff"
      }

    return colours

  formatData: ->
    data = @visualisation.get('data').results
    xAxis = @visualisation.getXAxis()
    yAxis = @visualisation.getYAxis()
    subIndicatorField = @visualisation.get('indicator')
      .get('indicatorDefinition').subIndicatorField

    labels = _.map(data, (row) =>
      row.formatted[xAxis]
    )

    datasets = []
    for row in data
      for subIndicatorRecord, subIndicatorIndex in row[subIndicatorField]
        datasets[subIndicatorIndex] ||= {data: []}

        colourRange = @generateColourRange()
        _.extend(datasets[subIndicatorIndex], colourRange[subIndicatorIndex])

        datasets[subIndicatorIndex].title = subIndicatorRecord.station
        datasets[subIndicatorIndex].data.push subIndicatorRecord[yAxis]

    @renderLegend(datasets)

    return {
      labels: labels
      datasets: datasets
    }

  renderLegend: (datasets) ->
    $legend = @$el.find('.legend')
    legendTemplate = Handlebars.templates['line_chart_legend.hbs']

    datasets.forEach( (dataset) ->
      $title = legendTemplate(
        title: dataset.title
        backgroundColor: dataset.strokeColor
      )

      $legend.append($title)
    )

  renderChart: ->
    context = @$el.find('#line_chart').get(0).getContext('2d')
    lineChart = new Chart(context).Line(@formatData(),
      {bezierCurve: false, animation: false})

  onClose: ->
    @stopListening()
