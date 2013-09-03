window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IntegerFilterView extends Backbone.View
  template: Handlebars.templates['integer_filter.hbs']

  initialize: (options) ->
    @render()

  render: ->
    @$el.html(@template())
    return @

  onClose: ->
    
