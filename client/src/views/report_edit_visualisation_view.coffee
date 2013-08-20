window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportEditVisualisationView extends Backbone.Diorama.NestingView
  className: 'report-edit-visualisation'
  template: Handlebars.templates['report_edit_visualisation.hbs']

  events:
    "click .close-vis-edit": "closeModal"
    "click .save": "save"
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

  closeModal: ->
    $('body').removeClass('stop-scrolling')
    @close()

  onClose: ->
    @closeSubViews()
    @stopListening()

  updateVisualisationType: =>
    type = @$el.find("select[name='visualisation']").val()
    @visualisation.set('type', type)
