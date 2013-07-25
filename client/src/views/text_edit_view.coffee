window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TextEditView extends Backbone.View
  template: Handlebars.templates['text-content.hbs']
  editTemplate: Handlebars.templates['text-edit.hbs']

  events:
    "click .save-content": "saveContent"
    "click .add-content": "startEdit"
    "click .content-text": "startEdit"

  initialize: (options) ->
    @type   = options.type
    @report = options.report

    @render()

  render: (options = {}) =>
    template = options.edit ? @editTemplate : @template

    @$el.html(template(content: @report.get(@type), type: @type))

    return @

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
    
