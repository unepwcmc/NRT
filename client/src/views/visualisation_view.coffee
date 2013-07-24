window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.VisualisationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['visualisation.hbs']

  initialize: (options) ->
    @render()

  render: =>
    @closeSubViews()
    @$el.html(@template(thisView: @))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
