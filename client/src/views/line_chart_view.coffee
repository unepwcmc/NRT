window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.LineChartView extends Backbone.View
  template: Handlebars.templates['line_chart.hbs']

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

  generateColourRange: (r, g, b, limit) ->
    colours = []

    for index in [1..limit]
      step = Math.floor(255/Math.max(limit, 4))
      r = Math.min(r+step, 255)
      g = Math.min(g+step, 255)
      b = Math.min(b+step, 255)

      rgbString = "#{r},#{g},#{b}"
      colours.push {
        fillColor: "rgba(#{rgbString}, 0)"
        strokeColor: "rgba(#{rgbString}, 1)"
        pointColor: "rgba(#{rgbString}, 1)"
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

        colourRange = @generateColourRange(15, 10, 255, row[subIndicatorField].length)
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

    datasets.forEach( (dataset) ->
      $title = $("
        <li>
          <span style=\"background-color: #{dataset.strokeColor}\"></span>
          #{dataset.title}
        </li>
      ")

      $legend.append($title)
    )

  renderChart: ->
    context = @$el.find('#line_chart').get(0).getContext('2d')
    lineChart = new Chart(context).Line(@formatData(),
      {bezierCurve: false, datasetStrokeWidth: 4, animation: false})

  onClose: ->
    @stopListening()
