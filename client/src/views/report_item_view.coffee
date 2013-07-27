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
    @bookmarked = !@bookmarked
    @render()

  render: =>
    @$el.html(@template(report: @model))

    if @bookmarked
      $(".report-bookmark i").addClass("selected")
      $(".report-bookmark span").text("Bookmarked")

    return @

  onClose: ->
    
