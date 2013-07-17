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
    @editMode = true

    @narrative.bind('change', @render)
    @render()

  render: =>
    if @editMode
      @$el.html(@editTemplate(@narrative.toJSON()))
    else
      @$el.html(@template(@narrative.toJSON()))
    return @

  saveNarrative: (event) =>
    @editMode = false
    @narrative.set('body', @$el.find('.body-text-field').val())

  startEdit: =>
    @editMode = true
    @render()

  onClose: ->
    
