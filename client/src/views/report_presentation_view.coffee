window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportPresentationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report-presentation.hbs']
  el: "<div class='slides'>"

  initialize: (options) ->
    @report = options.report
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @,
      report: @report.toJSON()
      sections: @report.get('sections').models
      coverImage: => @report.get('img')()
      updatedAt: => moment(@report.get('updatedAt')).fromNow()
    ))
    @renderSubViews()

    reveal = RevealAbused()
    _.delay reveal.initialize, 500

    return @

  onClose: ->
    @closeSubViews()
