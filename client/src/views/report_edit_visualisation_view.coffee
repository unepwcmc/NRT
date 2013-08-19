window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportEditVisualisationView extends Backbone.Diorama.NestingView
  className: 'report-edit-visualisation'
  template: Handlebars.templates['report_edit_visualisation.hbs']

  events:
    "click .close-vis-edit": "closeModal"

  initialize: (options) ->
    @visualisation = options.visualisation
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      indicator: @visualisation.get('indicator').toJSON()
      visualisation: @visualisation
    ))
    @renderSubViews()

    return @

  closeModal: ->
    $('body').removeClass('stop-scrolling')
    @close()

  onClose: ->
    @closeSubViews()
