window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NarrativeView extends Backbone.View
  template: Handlebars.templates['narrative.hbs']
  editTemplate: Handlebars.templates['narrative-edit.hbs']

  events:
    "click .save-narrative": "saveNarrative"
    "click .content-text": "startEdit"

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
    @narrative.set('title', "title")
    @narrative.set('content', @$el.find('.content-text-field').val().replace(/^\s+|\s+$/g, ''))
    @narrative.set('editing', false)
    @narrative.save()

  startEdit: =>
    @narrative.set('editing', true)
    @render()

  onClose: ->
    
