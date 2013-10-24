window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorItemView extends Backbone.View
  template: Handlebars.templates['indicator_selector_item.hbs']

  tagName: 'li'

  events:
    "click .info": "selectIndicator"

  initialize: (options) ->
    @indicator = options.indicator
    @section   = options.section
    @render()

  selectIndicator: ->
    @section.set('indicator', @indicator)
    @section.save(
      success: =>
        @addVisualisation()
    )

  createVisualisation: =>
    @section.set('visualisation', indicator: @section.get('indicator'))

  addVisualisation: =>
    unless @section.get('visualisation')
      @createVisualisation()

    editVisualisationView = new Backbone.Views.ReportEditVisualisationView(
      visualisation: @section.get('visualisation')
    )

    $('body').append(editVisualisationView.render().el)

    @trigger('indicatorSelected')

  render: =>
    @$el.html(@template(title: @indicator.get('title')))

  onClose: ->
