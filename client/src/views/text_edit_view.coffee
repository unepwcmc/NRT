window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-content.hbs']

  events:
    "blur :input, .content-text-field": "delaySave"
    "keyup .content-text-field"  : "delaySave"

  initialize: (options) ->
    @model = options.model
    @attributeName = options.attributeName
    if options.wrapperTag? then @wrapperTag = options.wrapperTag

    @render()

  render: (options = {}) =>
    content = @model.get(@attributeName) || ""

    @$el.html(@template(
      content: content
      wrapperTag: @wrapperTag || 'div'
    ))

    return @

  getContent: =>
    @$el.find('.content-text-field').text()

  delaySave: =>
    if @startDelayedSave?
      clearTimeout @startDelayedSave

    @startDelayedSave = setTimeout @saveContent, 1000

  saveContent: (event) =>
    console.log 'saved'
    @model.set(@attributeName, @getContent())

    @model.save()

  onClose: ->

