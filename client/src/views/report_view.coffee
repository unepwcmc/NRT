window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report.hbs']

  events:
    "click .add-report-section": "addSection"

  initialize: (options) ->
    @report = options.report
    @report.bind('change', @updateUrl)
    @report.get('sections').bind('add', @render)
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

  # TODO This isn't a great long-term approach, since it won't work in IE
  # plus, it should probably defer to a router
  updateUrl: =>
    if @report.get('_id')?
      window.history.replaceState(
        {},
        "Report #{@report.get('_id')}",
        "/reports/#{@report.get('_id')}"
      )

  addSection: =>
    if @report.get('_id')?
      section = new Backbone.Models.Section(report_id: @report.get('_id'))
      @report.get('sections').add(section)
      section.save()
    else
      @report.save(null,
        success: @addSection
      )

  onClose: ->
    @closeSubViews()
