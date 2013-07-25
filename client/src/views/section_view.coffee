window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section.hbs']
  tagName: 'section'

  events:
    "click .add-narrative": "addNarrative"

  initialize: (options) ->
    @section = options.section

    @section.get('narratives').bind('add', @render)
    @section.get('narratives').bind('sync', @render)

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      narratives: @section.get('narratives').models
      visualisations: @section.get('visualisations').models
    ))
    @renderSubViews()

    return @

  addNarrative: =>
    newNarrative = new Backbone.Models.Narrative()
    @section.get('narratives').add(newNarrative)

  onClose: ->
    @closeSubViews()
