window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.BriefView extends Backbone.View
  template: Handlebars.templates['brief.hbs']
  editTemplate: Handlebars.templates['brief-edit.hbs']

  events:
    "click .save-brief": "saveBrief"
    "click .content-text": "startEdit"
    "click .add-brief": "startEdit"

  initialize: (options) ->
    @report = options.report

    @render()

  render: (options = {}) =>
    template = @template
    template = @editTemplate if options.edit

    @$el.html(template(brief: @report.get('brief')))

    return @

  saveBrief: (event) =>
    @report.set('brief',
      @$el.find('.content-text-field').
      val().
      replace(/^\s+|\s+$/g, '')
    )

    @report.save()
    @render()

  startEdit: =>
    @render(edit: true)

  onClose: ->
    
