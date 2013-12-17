window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.VisualisationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['visualisation.hbs']

  events:
    "click .download-indicator": "downloadAsCsv"
    "click .view-indicator": "downloadAsJson"

  initialize: (options) ->
    @visualisation = options.visualisation

    @render()

  downloadAsJson: ->
    window.location = @visualisation.buildIndicatorDataUrl()

  downloadAsCsv: ->
    window.location = @visualisation.buildIndicatorDataUrl('csv')

  render: =>
    @$el.html(@template(
      thisView: @
      visualisation: @visualisation
      visualisationViewName: @visualisation.get('type') + "View"
    ))
    @attachSubViews()

    return @

  onClose: ->
    @closeSubViews()
