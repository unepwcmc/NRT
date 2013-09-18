window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section.hbs']
  tagName: 'section'
  className: 'section-view'

  events:
    "click .add-title": "startTitleEdit"
    "click .choose-indicator": "chooseIndicator"
    "click .add-narrative": "addNarrative"
    "click .add-visualisation": "editVisualisation"
    "click .bar-chart-view": "editVisualisation"
    "click .visualisation-table-view": "editVisualisation"
    "click .map-view": "editVisualisation"

  initialize: (options) ->
    @section = options.section
    @section.bind('change', @render)
    @render()

  render: =>
    @closeSubViews()

    noContent = !@section.get('narrative')? and !@section.get('visualisation')?
    if @section.get('indicator')?
      sectionIndicatorJSON = @section.get('indicator').toJSON()

    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      sectionIndicator: sectionIndicatorJSON
      sectionModel: @section
      noContent: noContent
      noTitleOrIndicator: !@section.hasTitleOrIndicator()
      narrative: @section.get('narrative')
      visualisation: @section.get('visualisation')
    ))
    @renderSubViews()
    return @

  startTitleEdit: =>
    @section.set('title', 'New Section')

  chooseIndicator: =>
    return if @section.get('indicator')

    indicatorSelectorView = new Backbone.Views.IndicatorSelectorView(
      section: @section
    )

    @$el.append(indicatorSelectorView.render().el)

  addNarrative: =>
    narrative = new Backbone.Models.Narrative(
      section_id: @section.get(Backbone.Models.Section.idAttribute)
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
    ###
    @section.set('visualisation', visualisation)
    visualisation.save()
    ###

  onClose: ->
    @closeSubViews()
