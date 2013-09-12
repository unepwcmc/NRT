window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportEditVisualisationView extends Backbone.Diorama.NestingView
  className: 'modal report-edit-visualisation'
  template: Handlebars.templates['report_edit_visualisation.hbs']

  events:
    "click .close": "close"
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
    $('body').addClass('stop-scrolling')

    return @

  save: ->
    @visualisation.save()

  onClose: ->
    $('body').removeClass('stop-scrolling')
    @trigger('close')
    @closeSubViews()
    @stopListening()

  updateVisualisationType: =>
    type = @$el.find("select[name='visualisation']").val()
    @visualisation.set('type', type)
