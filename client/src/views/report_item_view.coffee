window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportItemView extends Backbone.View
  template: Handlebars.templates['report_item.hbs']

  events:
    'click .report-bookmark': 'toggleBookmarked'

  initialize: (options) ->
    @model = options.report

    @render()

  toggleBookmarked: ->
    @model.set('bookmarked', true)

  render: =>
    @$el.html(@template(report: @model.toJSON()))

    return @

  onClose: ->
    
