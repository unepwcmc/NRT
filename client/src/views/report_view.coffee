window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report.hbs']

  initialize: (options) ->
    @report = options.report
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @,
      report: @report.toJSON()
      sections: @report.get('sections').models
    ))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
