window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-edit.hbs']

  className: 'show-content content-text-field'

  events:
    "click": "showEditingView"

  initialize: (options) ->
    @model = options.model
    @attributeName = options.attributeName
    @tagName = options.tagName || 'div'

    @render()

  render: (options = {}) =>
    content = @model.get(@attributeName) || i18n.t("report/type_here")

    @$el.html(@template(
      content: content
    ))

    return @

  showEditingView: ->
    unless @editingView?
      @$el.addClass('editing')
      @editingView = new Backbone.Views.TextEditingView(
        tagName: @tagName
        position: @$el.offset()
        model: @model
        attributeName: @attributeName
      )
      @setupEditingViewBindings()
      @$el.append(@editingView.el)

  setupEditingViewBindings: =>
    @listenTo(@editingView, 'close', @editingFinished)
    @listenTo(@editingView, 'sizeUpdated', @resizeView)

  editingFinished: =>
    @$el.removeClass('editing')
    @editingView = null
    @saveContent()
    @render()

  replaceContent: ->
    content = @model.get(@attributeName)
    content = content.replace(/\n/g, "<br>")
    @$el.html(content)

  resizeView: (size) =>
    @$el.css(size)

  saveContent: =>
    Backbone.trigger 'save', 'saving'
    saveState = @model.save()
    saveState.done =>
      Backbone.trigger 'save', 'saved'

  onClose: ->
    @stopListening()
