window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NarrativeView extends Backbone.View
  template: Handlebars.templates['narrative.hbs']
  editTemplate: Handlebars.templates['narrative-edit.hbs']

  events:
    "click .save-narrative": "saveNarrative"
    "click .body-text": "startEdit"

  initialize: (options) ->
    @narrative = options.narrative

    @narrative.bind('change', @render)
    @render()

  render: =>
    if @narrative.get('editing')
      @$el.html(@editTemplate(@narrative.toJSON()))
    else
      @$el.html(@template(@narrative.toJSON()))
    return @

  saveNarrative: (event) =>
    @narrative.set('body', @$el.find('.body-text-field').val())
    @narrative.set('editing', false)

  startEdit: =>
    @narrative.set('editing', true)
    @render()

  onClose: ->
    
