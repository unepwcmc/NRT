window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report.hbs']

  events:
    "click .add-report-section": "addSection"
    "click .add-report-chapter": "addChapter"

  initialize: (options) ->
    @report = options.report

    unless @report.get('page')?
      @report.set('page', new Backbone.Models.Page(parent: @report))

    @page = @report.get('page')

    @listenTo(@report, "change:#{Backbone.Models.Report::idAttribute}", @updateUrl)
    @listenTo(@page.get('sections'), 'add', @render)
    @listenTo(@page.get('sections'), 'reset', @render)
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @,
      report: @report.toJSON()
      sectionsWithViewName: @getSectionsWithViewNames()
      sections: @page.get('sections')
    ))
    @renderSubViews()

    return @

  getSectionsWithViewNames: ->
    sectionsWithViewNames = _.map(@page.get('sections').models, (section) ->
      viewName: "#{section.get('type')}View", section: section
    )

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
      section = new Backbone.Models.Section()
      @page.get('sections').add(section)
    else
      @report.save(null,
        success: @addSection
        error: (err) ->
          console.log err
          alert('Unable to save report, please try again')
      )

  addChapter: =>
    if @report.get('_id')?
      section = new Backbone.Models.Section(type: 'Chapter')
      @page.get('sections').add(section)
    else
      @report.save(null,
        success: @addChapter
        error: (err) ->
          console.log err
          alert('Unable to save report, please try again')
      )

  onClose: ->
    @stopListening()
    @closeSubViews()
