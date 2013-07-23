window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report.hbs']

  initialize: (options) ->
    @report = options.report
    @render()

  render: =>
    @closeSubViews()
    sections = []
    if @report.get('sections')
      sections = @report.get('sections')
    @$el.html(@template(
      thisView: @,
      report: @report.toJSON()
      sections: sections
    ))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
