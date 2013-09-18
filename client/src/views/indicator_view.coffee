window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator.hbs']

  initialize: (options) ->
    @indicator = options.indicator
    @render()

  render: ->
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      sections: @indicator.get('sections')
    ))

    @renderSubViews()
    return @

  onClose: ->
    @closeSubViews()
