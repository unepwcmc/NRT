window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportListView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report_list.hbs']

  initialize: (options) ->
    @reports = new Backbone.Collections.ReportCollection()
    @reports.reset options.reports

    @listenTo @reports, 'change', @render
    @listenTo @reports, 'reset', @render

    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @,
      reports: @reports.models
    ))
    @renderSubViews()

    return @

  onClose: ->
    @stopListening()
    @closeSubViews()
