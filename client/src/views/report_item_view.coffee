window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportItemView extends Backbone.View
  template: Handlebars.templates['report_item.hbs']

  initialize: (options) ->
    @model = options.report

    @render()

  render: =>
    @$el.html(@template(report: @model))

    return @

  onClose: ->
    
