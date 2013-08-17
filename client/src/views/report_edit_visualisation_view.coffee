window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportEditVisualisationView extends Backbone.Diorama.NestingView
  className: 'report-edit-visualisation'
  template: Handlebars.templates['report_edit_visualisation.hbs']

  events:
    "click .close-vis-edit": "close"

  initialize: (options) ->
    @indicator = options.indicator
    @visualisation = options.visualisation
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      indicator: @indicator.toJSON()
      visualisation: @visualisation
    ))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
