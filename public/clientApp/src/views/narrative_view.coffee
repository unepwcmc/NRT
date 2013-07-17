window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NarrativeView extends Backbone.View
  template: Handlebars.templates['narrative.hbs']

  initialize: (options) ->
    @narrative = options.narrative
    @render()

  render: ->
    @$el.html(@template())
    return @

  onClose: ->
    
