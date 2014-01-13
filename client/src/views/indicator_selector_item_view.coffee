window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorItemView extends Backbone.View
  template: Handlebars.templates['indicator_selector_item.hbs']

  tagName: 'li'

  events:
    "click": "selectIndicator"

  initialize: (options) ->
    @indicator = options.indicator
    @render()

  selectIndicator: =>
    Backbone.trigger('indicator_selector:indicator_selected', @indicator)

  render: =>
    @$el.html(@template(@indicator.toJSON()))

  onClose: ->
