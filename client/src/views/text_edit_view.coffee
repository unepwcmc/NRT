window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-edit.hbs']

  className: 'show-content content-text-field'

  events:
    "click": "showEditingView"

  initialize: (options) ->
    @model = options.model

    @determineEditModeFromModel()

    @attributeName = options.attributeName
    @tagName = options.tagName || 'div'
    @disableNewlines = options.disableNewlines || false

    @render()

  render: (options = {}) =>
    content = @model.get(@attributeName)

    @$el.html(@template(
      content: content
    ))

    return @

  determineEditModeFromModel: ->
    @editMode = true
    if typeof @model.getPage is 'Function'
      page = @model.getPage()
      @editMode = if page? then page.get('is_draft') else false

  showEditingView: ->
    unless @editingView?
      @$el.addClass('editing')
      @editingView = new Backbone.Views.TextEditingView(
        tagName: @tagName
        position: @getPositionRelativeToViewport()
        content: @model.get(@attributeName)
        disableNewlines: @disableNewlines
      )
      @setupEditingViewBindings()
      @$el.append(@editingView.el)

  getPositionRelativeToViewport: =>
    top: @$el.offset().top - $(window).scrollTop()
    left: @$el.offset().left - $(window).scrollLeft()

  setupEditingViewBindings: =>
    @listenTo(@editingView, 'close', @editingFinished)
    @listenTo(@editingView, 'sizeUpdated', @resizeView)

  editingFinished: (newContent) =>
    @model.set(@attributeName, newContent)
    @$el.removeClass('editing')
    @editingView = null
    @saveContent()
    @render()

  resizeView: (size) =>
    @$el.css(size)

  saveContent: =>
    Backbone.trigger 'save', 'saving'
    saveState = @model.save()
    saveState.done =>
      Backbone.trigger 'save', 'saved'

  onClose: ->
    @stopListening()
