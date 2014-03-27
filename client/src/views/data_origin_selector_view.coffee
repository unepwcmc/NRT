window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.DataOriginSelectorView extends Backbone.View
  template: Handlebars.templates['data_origin_selector.hbs']
  className: 'origin'

  events:
    'change select': 'triggerSelected'

  initialize: (options) ->
    @indicators = options.indicators
    @listenTo(@indicators, 'reset', @render)
    @render()

  triggerSelected: ->
    originName = @$el.find('select').val()
    originName = undefined if originName is ""

    Backbone.trigger('indicator_selector:data_origin:selected', originName)

  render: =>
    @$el.html(@template(
      origins: @indicators.getSources()
    ))

    FancySelect.fancify(@$el)

    return @

  onClose: ->
    @stopListening()
