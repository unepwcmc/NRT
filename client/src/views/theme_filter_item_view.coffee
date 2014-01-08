window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ThemeFilterItemView extends Backbone.View
  tagName: 'li'

  template: Handlebars.templates['theme_filter_item.hbs']

  initialize: (options) ->
    @theme = options.theme
    @render()

  render: ->
    @$el.html(@template(
      @theme.toJSON()
    ))
    return @

  onClose: ->
    
