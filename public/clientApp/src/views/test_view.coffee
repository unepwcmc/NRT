window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.TestView extends Backbone.View
  template: Handlebars.templates['test.hbs']

  initialize: (options) ->
    @render()

  render: ->
    @$el.html(@template())
    return @

  onClose: ->
    
