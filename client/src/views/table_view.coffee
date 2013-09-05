window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TableView extends Backbone.View
  template: Handlebars.templates['table.hbs']

  className: 'visualisation-table-view'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, 'change', @render)

  render: =>
    @visualisation.getIndicatorData((error, data) =>
      @$el.html(@template(
        xAxis: @visualisation.getXAxis()
        yAxis: @visualisation.getYAxis()
        dataRows: @visualisation.mapDataToXAndY()
        indicatorTitle: @visualisation.get('indicator').get('title')
      ))
    )

    return @

  onClose: ->
    
