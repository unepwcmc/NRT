window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section.hbs']
  tagName: 'section'
  className: 'section-view'

  events:
    "click .add-narrative": "addNarrative"
    "click .add-visualisation": "addVisualisation"

  initialize: (options) ->
    @section = options.section
    @section.bind('change', @render)

  render: =>
    @closeSubViews()
    noContent = !@section.get('narrative')? and !@section.get('visualisation')?
    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      sectionModel: @section
      noContent: noContent
      narrative: @section.get('narrative')
      visualisation: @section.get('visualisation')
      indicator: window.randomIndicatorName()
    ))
    @renderSubViews()
    return @

  addNarrative: =>
    narrative = new Backbone.Models.Narrative(
      section_id: @section.get('id')
      editing: true
    )
    @section.set('narrative', narrative)

  addVisualisation: =>
    visualisation = new Backbone.Models.Visualisation(
      section_id: @section.get('id')
    )
    @section.set('visualisation', visualisation)
    visualisation.save()

  onClose: ->
    @closeSubViews()
