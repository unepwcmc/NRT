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
    @model.set('bookmarked', !@model.get('bookmarked'))

  render: =>
    @$el.html(@template(
      report: @model.toJSON()
      # This will be replaced with an actual user lookup
      author: @model.get('author')
    ))

    return @

  onClose: ->
    
