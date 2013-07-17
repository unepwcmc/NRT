window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section.hbs']

  events:
    "click .add-narrative": "addNarrative"

  initialize: (options) ->
    @narratives = options.narratives

    @narratives.bind('add', @render)
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(thisView: @, narratives: @narratives.models))
    @renderSubViews()

    return @

  addNarrative: =>
    newNarrative = new Backbone.Models.Narrative()
    @narratives.push(newNarrative)

  onClose: ->
    @closeSubViews()
