window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorItemView extends Backbone.View
  template: Handlebars.templates['indicator_selector_item.hbs']

  tagName: 'li'

  events:
    "click": "selectIndicator"

  initialize: (options) ->
    @indicator = options.indicator
    @listenTo(@indicator, 'change:theme', @render)
    @render()

  selectIndicator: =>
    Backbone.trigger('indicator_selector:indicator_selected', @indicator)

  render: =>
    indicatorJSON = @indicator.toJSON()
    theme = @indicator.get('theme')
    if theme?
      indicatorJSON.theme = theme.toJSON()

    @$el.html(@template(indicatorJSON))

  onClose: ->
    @stopListening()
