window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section.hbs']
  tagName: 'section'
  className: 'section-view'

  events:
    "click .add-narrative": "addNarrative"
    "click .add-visualisation": "editVisualisation"
    "click .bar-chart-view": "editVisualisation"
    "click .visualisation-table-view": "editVisualisation"
    "click .map-view": "editVisualisation"

  initialize: (options) ->
    @section = options.section

    @addDefaultTitleIfNotSet()

    @section.bind('change', @render)
    @render()

  render: =>
    @closeSubViews()

    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      sectionModel: @section
      narrative: @section.get('narrative')
      visualisation: @section.get('visualisation')
      isEditable: @section.isEditable()
    ))

    @renderSubViews()
    return @

  addDefaultTitleIfNotSet: =>
    unless @section.get('title')?
      @section.set('title', 'New Section')

  addNarrative: =>
    narrative = new Backbone.Models.Narrative(
      section_id: @section.get(Backbone.Models.Section.idAttribute)
      content: ''
    )
    @section.set('narrative', narrative)

  createVisualisation: =>
    return new Backbone.Models.Visualisation(
      section: @section
      indicator: @section.get('indicator')
    )

  editVisualisation: =>
    unless @section.get('visualisation')
      @createVisualisation()

    editVisualisationView = new Backbone.Views.ReportEditVisualisationView(
      visualisation: @section.get('visualisation')
    )

    @listenToOnce(editVisualisationView, 'close', @render)

    $('body').append(editVisualisationView.render().el)

  onClose: ->
    @closeSubViews()
