window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.LineChartView extends Backbone.View
  template: Handlebars.templates['line_chart.hbs']

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change:data', @render)

    @render()

  render: ->
    if @visualisation.get('data')?
      @renderChart()
    else
      @visualisation.getIndicatorData()

    return @

  formatData: ->
    data = @visualisation.get('data').results
    xAxis = @visualisation.getXAxis()
    yAxis = @visualisation.getYAxis()
    subIndicatorField = @visualisation.get('indicator')
      .get('indicatorDefinition').subIndicatorField

    labels = _.map(data, (row) ->
      row[xAxis]
    )

    datasets = []
    for row in data
      for subIndicatorRecord, subIndicatorIndex in row[subIndicatorField]
        datasets[subIndicatorIndex] ||= {data: []}

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
    lineChart = new Chart(context).Line(@formatData())

  onClose: ->
    
