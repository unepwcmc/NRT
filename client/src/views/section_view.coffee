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

  render: =>
    @closeSubViews()
    noContent = !@section.get('narrative')? and !@section.get('visualisation')?
    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      noContent: noContent
      narrative: @section.get('narrative')
      visualisation: @section.get('visualisation')
    ))
    @renderSubViews()
    return this

  addNarrative: =>
    narrative = new Backbone.Models.Narrative()
    @section.set('narrative', narrative)
    @render()
    return narrative

  addVisualisation: =>
    @section.set('visualisation', new Backbone.Models.Visualisation())
    @render()

  onClose: ->
    @closeSubViews()
