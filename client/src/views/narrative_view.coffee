window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NarrativeView extends Backbone.View
  template: Handlebars.templates['narrative.hbs']
  editTemplate: Handlebars.templates['narrative-edit.hbs']

  events:
    "click .save-narrative": "saveNarrative"
    "click .content-text": "startEdit"
    # textarea resize-related events
    "change textarea.content-text-field": "resize"
    "cut textarea.content-text-field": "delayedResize"
    "paste textarea.content-text-field": "delayedResize"
    "drop textarea.content-text-field": "delayedResize"
    "keydown textarea.content-text-field": "delayedResize"

  initialize: (options) ->
    @narrative = options.narrative
    @narrative.bind('change', @render)

  render: =>
    # `editing` defaults to true on the model
    # I assume it is going to be the default state unless a section is 
    # `locked` from another user.
    if @narrative.get('editing')
      @$el.html(@editTemplate(@narrative.toJSON()))
      @text = @$el.find("textarea.content-text-field")
      @text.focus()
      @text.select()
      @resize()
    else
      @$el.html(@template(@narrative.toJSON()))
    return @

  saveNarrative: (event) =>
    @narrative.set(
      content: @$el.find('.content-text-field').val().replace(/^\s+|\s+$/g, '')
      editing: false
    )
    @narrative.save()

  # Following 2 methods are used for dynamically resize the textarea.
  # From: http://goo.gl/9gRC4H

  resize: =>
    @text.css("height", "auto")
    @text.css("height", @text[0].scrollHeight + "px")
  
  # Used to push the resize method onto the event queue, 
  # ensuring it actually gets evaluated after the events have completed.
  delayedResize: ->
    setTimeout @resize, 0

  startEdit: =>
    @narrative.set('editing', true)

  onClose: ->


