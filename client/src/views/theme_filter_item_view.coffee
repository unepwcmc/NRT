window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ThemeFilterItemView extends Backbone.View
  tagName: 'li'

  events:
    'click': 'triggerSelected'

  template: Handlebars.templates['theme_filter_item.hbs']

  initialize: (options) ->
    @theme = options.theme

    @listenTo(Backbone, 'indicator_selector:theme_selected', @deactivate)

    @render()

  deactivate: ->
    @$el.removeClass('active')

  triggerSelected: =>
    Backbone.trigger('indicator_selector:theme_selected', @theme)
    @$el.addClass('active')

  render: ->
    @$el.html(@template(
      @theme.toJSON()
    ))
    return @

  onClose: ->
