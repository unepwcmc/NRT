window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ThemeFiltersView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['theme_filters.hbs']

  tagName: 'ul'
  className: 'themes'

  events:
    'click .all-indicators': 'showAllIndicators'

  initialize: (options) ->
    @themes = options.themes
    @listenTo(@themes, 'sync', @render)

    @listenTo(Backbone, 'indicator_selector:theme_selected', @deactivateAllIndicators)

    @render()

  render: ->
    @$el.html(@template(
      thisView: @
      themes: @themes.models
    ))
    @attachSubViews()

    return @

  deactivateAllIndicators: ->
    @$el.find('.all-indicators').removeClass('active')

  showAllIndicators: (event) ->
    Backbone.trigger('indicator_selector:theme_selected')
    $(event.target).addClass('active')

  onClose: ->
    @stopListening()
    @closeSubViews()
