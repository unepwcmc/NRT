window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-content.hbs']
  editTemplate: Handlebars.templates['text-edit.hbs']

  events:
    "click .save-content": "saveContent"
    "click .add-content": "startEdit"
    "click .content-text": "startEdit"
    "change .content-text-field": "resize"
    "cut .content-text-field": "delayedResize"
    "paste .content-text-field": "delayedResize"
    "drop .content-text-field": "delayedResize"
    "keydown .content-text-field": "delayedResize"
    "blur :input": "addPlaceholder"
    "keyup .content-text-field"  : "saveOnEnter"

  initialize: (options) ->
    @type   = options.type
    @model = options.model
    @attributeName = options.attributeName

    @render()

  render: (options = {}) =>
    content = @model.get(@attributeName) || ""

    if options.edit
      @$el.html(@editTemplate(
        isInput: (@type is 'input')
        content: content
      ))
    else
      @$el.html(@template(content: content, attributeName: @attributeName))

    @text = @$el.find(":input")
    @text.focus()
    @text.select()
    @resize()

    return @

  addPlaceholder: ->
    input = @$el.find(':input')
    if input.val().length == 0
      input.val("Type #{@attributeName} here")

  # Following 2 methods are used for dynamically resize the textarea.
  # From: http://goo.gl/9gRC4H

  resize: =>
    if @text.length > 0
      @text.css("height", "auto")
      @text.css("height", @text[0].scrollHeight + "px")

  # Used to push the resize method onto the event queue,
  # ensuring it actually gets evaluated after the events have completed.
  delayedResize: ->
    setTimeout @resize, 0

  saveContent: (event) =>
    @model.set(@attributeName,
      @$el.find(':input').
      val().
      replace(/^\s+|\s+$/g, '')
    )

    @model.save()
    @render()

  startEdit: =>
    @render(edit: true)

  saveOnEnter: (e) =>
    if e.keyCode == 13 && @type == 'input'
      @saveContent()

  onClose: ->
    
