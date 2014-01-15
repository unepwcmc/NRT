window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorResultsView extends Backbone.Diorama.NestingView
  tagName: 'ul'
  className: 'indicators'

  template: Handlebars.templates['indicator_selector_results.hbs']

  initialize: (options) ->
    @indicators = options.indicators
    console.log "Initializing IndicatorSelectorResultsView #{@cid}"

    @listenTo(@indicators, 'reset', @render)

    @render()

  render: ->
    @$el.empty().html(@template(
      indicators: @indicators.models
      thisView: @
    ))
    @attachSubViews()

    return @

  onClose: ->
    @stopListening()
