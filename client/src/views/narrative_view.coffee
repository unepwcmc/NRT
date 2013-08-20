window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NarrativeView extends Backbone.View
  template: Handlebars.templates['narrative.hbs']

  events:
    "blur .content-text-field": "delaySave"
    "keyup .content-text-field"  : "delaySave"

  initialize: (options) ->
    @narrative = options.narrative
    @narrative.bind('change', @render)

  render: =>
    @$el.html(@template(@narrative.toJSON()))
    return @

  getContent: =>
    @$el.find('.content-text-field').text()

  delaySave: =>
    if @startDelayedSave?
      clearTimeout @startDelayedSave

    @startDelayedSave = setTimeout @saveContent, 1500

  saveContent: (event) =>
    Backbone.trigger 'save', 'saving'
    @narrative.set(
      content: @$el.find('.content-text-field').text()
    )
    saveState = @narrative.save()
    saveState.done ->
      Backbone.trigger 'save', 'saved'

  onClose: ->


