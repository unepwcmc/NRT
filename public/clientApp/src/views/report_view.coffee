window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ReportView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['report.hbs']

  initialize: (options) ->
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(thisView: @))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
