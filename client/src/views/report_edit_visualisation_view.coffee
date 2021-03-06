window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportEditVisualisationView extends Backbone.Diorama.NestingView
  className: 'modal edit-visualisation'
  template: Handlebars.templates['report_edit_visualisation.hbs']

  events:
    "click": "closeIfModalTarget"
    "click .close": "closeModal"
    "click .save": "save"
    "change select[name='visualisation']": 'updateVisualisationType'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo @visualisation, 'change', @render
    @render()

  render: =>
    @$el.html(@template(
      thisView: @
      indicator: @visualisation.get('indicator').toJSON()
      visualisation: @visualisation
      visualisationType: @visualisation.get('type')
      visualisationViewName: @visualisation.get('type') + "View"
      visualisationTypes: @visualisation.getVisualisationTypes()
    ))
    @attachSubViews()
    $('body').addClass('stop-scrolling')

    return @

  save: =>
    @visualisation.save()

  closeModal: ->
    @trigger('close')
    @close()

  closeIfModalTarget: (event) =>
    if event.target == @el
      @closeModal()

  onClose: ->
    $('body').removeClass('stop-scrolling')
    @closeSubViews()
    @stopListening()

  updateVisualisationType: =>
    type = @$el.find("select[name='visualisation']").val()
    @visualisation.set('type', type)
