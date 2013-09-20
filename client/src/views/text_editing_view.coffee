window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditingView extends Backbone.View
  template: Handlebars.templates['text_editing.hbs']
  className: "text-editing-view"

  initialize: (options) ->
    @tagName = options.tagName
    @setPosition(options.position)

    @disablerDiv = $('<div class="modal"/>')
    $('body').prepend(@disablerDiv)
    @render()

  render: ->
    @$el.html(@template())
    return @

  setPosition: (position) ->
    console.log position
    @$el.css(position)

  onClose: ->
    
