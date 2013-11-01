window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TableView extends Backbone.View
  template: Handlebars.templates['table.hbs']

  className: 'visualisation-table-view'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change:data', @render)
    @render()

  render: =>
    if @visualisation.get('data')?
      @renderTable()
    else
      @visualisation.getIndicatorData()

    return @

  renderTable: ->
    @$el.html(@template(
      xAxis: @visualisation.getXAxis()
      yAxis: @visualisation.getYAxis()
      dataRows: @visualisation.mapDataToXAndY()
      indicatorTitle: @visualisation.get('indicator').get('title')
    ))

  onClose: ->
    @stopListening()
