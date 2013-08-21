window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-edit.hbs']

  className: 'show-content content-text-field'

  attributes:
    'contenteditable': 'true'

  events:
    "blur": "delaySave"
    "keyup"  : "delaySave"

  initialize: (options) ->
    @model = options.model
    @attributeName = options.attributeName
    @tagName = options.tagName || 'div'

    @render()

  render: (options = {}) =>
    content = @model.get(@attributeName) || "Type here"

    @$el.html(@template(
      content: content
    ))

    return @

  getContent: =>
    @$el.text()

  delaySave: =>
    if @startDelayedSave?
      clearTimeout @startDelayedSave

    @startDelayedSave = setTimeout @saveContent, 1500

  saveContent: (event) =>
    Backbone.trigger 'save', 'saving'
    @model.set(@attributeName, @getContent())
    saveState = @model.save()
    saveState.done ->
      Backbone.trigger 'save', 'saved'

  onClose: ->

