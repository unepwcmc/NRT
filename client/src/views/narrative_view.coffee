window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NarrativeView extends Backbone.View
  template: Handlebars.templates['narrative.hbs']

  events:
    "blur :input, .content-text-field": "delaySave"
    "keyup .content-text-field"  : "delaySave"
    "click .save-narrative"  : "delaySave"

  initialize: (options) ->
    @narrative = options.narrative
    # @narrative.bind('change', @render)

  render: =>
    # console.log @narrative.toJSON()
    @$el.html(@template(@narrative.toJSON()))
    return @

  getContent: =>
    @$el.find('.content-text-field').text()

  delaySave: =>
    if @startDelayedSave?
      clearTimeout @startDelayedSave

    @startDelayedSave = setTimeout @saveContent, 1000

  saveContent: (event) =>
    @narrative.set(
      content: @$el.find('.content-text-field').text()
    )
    @narrative.save()
    console.log "saved"
    window.n = @narrative

  onClose: ->


