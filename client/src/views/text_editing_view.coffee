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
    @content = options.content

    @disablerDiv = $('<div class="modal"/>')
    $('body').prepend(@disablerDiv)
    $(@disablerDiv).click(@closeViewAndModal)

    $(document).on('scroll', @setPositionToParent)

    @render()

  render: ->
    @$el.html(@template(
      content: @content
    ))

    new MediumEditor(@$el,
      excludedActions: ['u', 'blockquote', 'h4', 'h3', 'b']
    )

    return @

  setPositionToParent: =>
    parentEl = @$el.parents('.editing')
    @setPosition(
      top: parentEl.offset().top - $(window).scrollTop()
      left: parentEl.offset().left - $(window).scrollLeft()
    )

  setPosition: (position) ->
    @$el.css(position)

  getContent: =>
    @$el.html()

  updateSize: =>
    @trigger('sizeUpdated', @getContentSize())

  getContentSize: ->
    {
      height: @$el.outerHeight()
      width: @$el.outerWidth()
    }

  closeViewAndModal: =>
    @disablerDiv.remove()
    @trigger('close', @getContent())
    $(document).off('scroll', @setPositionToParent)
    @close()

  onClose: ->
    $('.medium-editor-toolbar').remove()