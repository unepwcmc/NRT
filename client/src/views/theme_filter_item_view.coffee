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
    @listenTo(@theme, 'change:active', @render)

    @render()

  deactivate: ->
    @theme.set('active', false)

  triggerSelected: =>
    Backbone.trigger('indicator_selector:theme_selected', @theme)
    @theme.set('active', true)

  render: ->
    if @theme.get('active')
      @$el.addClass('active')
    else
      @$el.removeClass('active')

    @$el.html(@template(
      @theme.toJSON()
    ))
    return @

  onClose: ->
