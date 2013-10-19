window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.VisualisationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['visualisation.hbs']

  events:
    "click .download-indicator": "downloadAsCsv"
    "click .view-indicator": "downloadAsJson"

  initialize: (options) ->
    @visualisation = options.visualisation
    # If we haven't fixed the JSON saving bug - will be removed
    if typeof @visualisation.get('data') is 'string'
      @visualisation.set('data', Backbone.Faker.Reports.createFakeData())

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
