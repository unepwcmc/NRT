window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportPresentationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report-presentation.hbs']

  initialize: (options) ->
    @report = options.report
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @,
      report: @report.toJSON()
      sections: @report.get('sections')
    ))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
