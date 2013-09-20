window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-edit.hbs']

  className: 'show-content content-text-field'

  attributes:
    'contenteditable': 'true'

  events:
    "click": "showEditingView"

  initialize: (options) ->
    @model = options.model
    @attributeName = options.attributeName
    @tagName = options.tagName || 'div'

    @render()

  render: (options = {}) =>
    content = @model.get(@attributeName) || i18n.t("report/type_here")

    @$el.removeClass('editing')
    @$el.html(@template(
      content: content
    ))

    return @

  showEditingView: ->
    @editingView = new Backbone.Views.TextEditingView(
      tagName: @tagName
      position: @$el.offset()
    )
    @$el.append(@editingView.el)

  replaceContent: ->
    unless @$el.hasClass('editing')
      @$el.addClass('editing')
      content = @model.get(@attributeName)
      content = content.replace(/\n/g, "<br>")
      @$el.html(content)

  getContent: =>
    content = $('<div>')
      .html(@$el.html())
    content.html(
      content.html().replace(/(<br>)|(<br \/>)|(<p>)|(<\/p>)/g, "\r\n")
    )
    return content.text()

  delaySave: =>
    if @startDelayedSave?
      clearTimeout @startDelayedSave

    @startDelayedSave = setTimeout @saveContent, 2000

  delayedRender: =>
    if @startDelayedRender?
      clearTimeout @startDelayedRender

    @startDelayedRender = setTimeout @render, 1500

  saveContent: (event) =>
    Backbone.trigger 'save', 'saving'
    @model.set(@attributeName, @getContent())
    saveState = @model.save()
    saveState.done =>
      Backbone.trigger 'save', 'saved'

  onClose: ->

