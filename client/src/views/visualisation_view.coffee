window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.VisualisationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['visualisation.hbs']
  className: 'visualisation-view'

  events:
    "click .download-indicator": "downloadAsCsv"
    "click .view-indicator": "downloadAsJson"
    "click .delete-visualisation": "delete"

  initialize: (options) ->
    @visualisation = options.visualisation
    @section       = @visualisation.get('section')

    @render()

  downloadAsJson: ->
    window.location = @visualisation.buildIndicatorDataUrl()

  downloadAsCsv: ->
    window.location = @visualisation.buildIndicatorDataUrl('csv')

  render: =>
    @$el.html(@template(
      thisView: @
      indicator: @visualisation.get('indicator').toJSON()
      visualisation: @visualisation
      visualisationViewName: @visualisation.get('type') + "View"
      isEditable: @section?.isEditable()
    ))
    @attachSubViews()

    return @

  delete: (event) =>
    event.stopPropagation()
    @visualisation.destroy(
      wait: true
    ).fail(->
      alert('Unable to delete section, are you still connected to the internet?')
    )

  onClose: ->
    @closeSubViews()
