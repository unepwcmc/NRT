window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-content.hbs']
  editTemplate: Handlebars.templates['text-edit.hbs']

  events:
    "click .save-content": "saveContent"
    "click .add-content": "startEdit"
    "click .content-text": "startEdit"
    "change textarea.content-text-field": "resize"
    "cut textarea.content-text-field": "delayedResize"
    "paste textarea.content-text-field": "delayedResize"
    "drop textarea.content-text-field": "delayedResize"
    "keydown textarea.content-text-field": "delayedResize"

  initialize: (options) ->
    @type   = options.type
    @report = options.report

    @render()

  render: (options = {}) =>
    template = if options.edit then @editTemplate else @template

    @$el.html(template(content: @report.get(@type), type: @type))

    @text = @$el.find("textarea.content-text-field")
    @text.focus()
    @text.select()
    @resize()

    return @

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
    @report.set(@type,
      @$el.find('.content-text-field').
      val().
      replace(/^\s+|\s+$/g, '')
    )

    @report.save()
    @render()

  startEdit: =>
    @render(edit: true)

  onClose: ->
    
