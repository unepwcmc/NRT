window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section.hbs']
  tagName: 'section'

  events:
    "click .add-narrative": "addNarrative"

  initialize: (options) ->
    @section = options.section
    @narratives = new Backbone.Collections.NarrativeCollection()

    @narratives.bind('add', @render)
    @narratives.bind('sync', @render)

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      narratives: @narratives.models
    ))
    @renderSubViews()

    return @

  addNarrative: =>
    newNarrative = new Backbone.Models.Narrative()
    @narratives.push(newNarrative)

  onClose: ->
    @closeSubViews()
