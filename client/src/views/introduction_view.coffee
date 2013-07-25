window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IntroductionView extends Backbone.View
  template: Handlebars.templates['introduction.hbs']
  editTemplate: Handlebars.templates['introduction-edit.hbs']

  events:
    "click .save-introduction": "saveIntroduction"
    "click .content-text": "startEdit"
    "click .add-introduction": "startEdit"

  initialize: (options) ->
    @report = options.report

    @render()

  render: (options = {}) =>
    template = @template
    template = @editTemplate if options.edit

    @$el.html(template(introduction: @report.get('introduction')))

    return @

  saveIntroduction: (event) =>
    @report.set('introduction',
      @$el.find('.content-text-field').
      val().
      replace(/^\s+|\s+$/g, '')
    )

    @report.save()
    @render()

  startEdit: =>
    @render(edit: true)

  onClose: ->
    
