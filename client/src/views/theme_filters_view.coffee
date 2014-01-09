window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ThemeFiltersView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['theme_filters.hbs']

  tagName: 'ul'
  className: 'themes'

  initialize: (options) ->
    @themes = options.themes
    @listenTo(@themes, 'sync', @render)
    @render()

  render: ->
    console.log @themes.length
    @$el.html(@template(
      thisView: @
      themes: @themes.models
    ))
    @attachSubViews()
    return @

  onClose: ->
    @stopListening()
    @closeSubViews()
