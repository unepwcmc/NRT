window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportListView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report_list.hbs']

  initialize: (options) ->
    @reports = new Backbone.Collections.ReportCollection(options.reports)

    @listenTo @reports, 'change', @render
    @listenTo @reports, 'reset', @render

    @render()

  render: =>
    @$el.html(@template(
      thisView: @,
      reports: @reports.models
    ))
    @attachSubViews()

    return @

  onClose: ->
    @stopListening()
    @closeSubViews()
