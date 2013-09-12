window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.VisualisationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['visualisation.hbs']

  events:
    "click .download-visualisation": "download"

  initialize: (options) ->
    @visualisation = options.visualisation
    # If we haven't fixed the JSON saving bug - will be removed
    if typeof @visualisation.get('data') is 'string'
      @visualisation.set('data', Backbone.Faker.Reports.createFakeData())

  download: ->
    window.location = @visualisation.buildIndicatorCSVDownloadUrl()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      visualisation: @visualisation
      visualisationViewName: @visualisation.get('type') + "View"
    ))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
