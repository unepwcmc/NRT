window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorResultsView extends Backbone.Diorama.NestingView
  tagName: 'ul'

  template: Handlebars.templates['indicator_selector_results.hbs']

  initialize: (options) ->
    @indicators = options.indicators

    @listenTo(@indicators, 'reset', @render)

    @render()

  render: ->
    @$el.html(@template(
      indicators: @indicators.models
      thisView: @
    ))
    @attachSubViews()

    return @

  onClose: ->
    @stopListening()
