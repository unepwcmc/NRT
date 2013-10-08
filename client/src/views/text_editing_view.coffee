window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditingView extends Backbone.View
  template: Handlebars.templates['text_editing.hbs']
  className: "text-editing-view"

  events:
    "keyup": "updateSize"

  initialize: (options) ->
    @tagName = options.tagName
    @setPosition(options.position)
    @model = options.model
    @attributeName = options.attributeName

    @disablerDiv = $('<div class="modal"/>')
    $('body').prepend(@disablerDiv)
    $(@disablerDiv).click(@closeViewAndModal)
    @render()

  render: ->
    @$el.html(@template(
      content: @model.get(@attributeName)
    ))
    return @

  setPosition: (position) ->
    @$el.css(position)

  getContent: =>
    content = $('<div>')
      .html(@$el.html())
    content.html(
      content.html().replace(/(<br>)|(<br \/>)|(<p>)|(<\/p>)/g, "\r\n")
    )
    return content.text()

  updateSize: =>
    @trigger('sizeUpdated', @getContentSize())

  getContentSize: ->
    {
      height: @$el.outerHeight()
      width: @$el.outerWidth()
    }

  closeViewAndModal: =>
    @model.set(@attributeName, @getContent())
    @disablerDiv.remove()
    @trigger('close')
    @close()

  onClose: ->
