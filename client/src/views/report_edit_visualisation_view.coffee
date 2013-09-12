window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportEditVisualisationView extends Backbone.Diorama.NestingView
  className: 'modal report-edit-visualisation'
  template: Handlebars.templates['report_edit_visualisation.hbs']

  events:
    "click .close": "closeModal"
    "click .save": "save"
    "click .download": "download"
    "change select[name='visualisation']": 'updateVisualisationType'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo @visualisation, 'change', @render
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      indicator: @visualisation.get('indicator').toJSON()
      visualisation: @visualisation
      visualisationType: @visualisation.get('type')
      visualisationViewName: @visualisation.get('type') + "View"
      visualisationTypes: Backbone.Models.Visualisation.visualisationTypes
    ))
    @renderSubViews()

    return @

  save: ->
    @visualisation.save()

  download: ->
    window.location = @visualisation.buildIndicatorCSVDownloadUrl()

  closeModal: ->
    $('body').removeClass('stop-scrolling')
    @trigger('close')
    @close()

  onClose: ->
    @closeSubViews()
    @stopListening()

  updateVisualisationType: =>
    type = @$el.find("select[name='visualisation']").val()
    @visualisation.set('type', type)
