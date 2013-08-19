window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-content.hbs']

  events:
    "click .save-content": "saveContent"
    "click .show-content": "startEdit"
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
    if options.wrapperTag?
      @wrapperTag = options.wrapperTag

    @render()

  render: (options = {}) =>
    content = @model.get(@attributeName) || ""

    @$el.html(@template(
      isInput: (@type is 'input')
      content: content
      wrapperTag: @wrapperTag || 'div'
    ))

    @text = @$el.find(":input").not("button")
    @text.focus()
    @text.select()
    @resize()

    return @

  addPlaceholder: =>
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
    @finishEdit()

  startEdit: =>
    # Populate input with content
    @$el.find('content-text-field').val(@model.get(@attributeName))

    @$el.find('.show-content').hide()
    @$el.find('.edit-content').show()
    @delayedResize()

  finishEdit: =>
    # Update content with input
    @$el.find('.markedup-content').html(@model.get(@attributeName))
    @$el.find('.show-content').show()
    @$el.find('.edit-content').hide()
    @delayedResize()

  saveOnEnter: (e) =>
    if e.keyCode == 13 && @type == 'input'
      @saveContent()

  onClose: ->

