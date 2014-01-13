window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ThemeFiltersView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['theme_filters.hbs']

  tagName: 'ul'
  className: 'themes'

  events:
    'click .all-indicators': 'showAllIndicators'

  initialize: (options) ->
    @indicators = options.indicators
    @listenTo(@indicators, 'reset', @render)

    @themes = new Backbone.Collections.ThemeCollection()
    @listenTo(@themes, 'sync', @render)

    @themes.fetch()
      .fail( (err) ->
        console.error "Error populating collections"
        console.error err
      )

    @render()

  render: ->
    @themes.populateIndicatorCounts(@indicators)

    @$el.html(@template(
      thisView: @
      themes: @themes.models
      allIndicatorsFilterActive: @allIndicatorsFilterActive()
    ))
    @attachSubViews()

    return @

  allIndicatorsFilterActive: ->
    active = true
    @themes.each( (theme) ->
      active = false if theme.get('active')
    )

    return active

  showAllIndicators: (event) ->
    Backbone.trigger('indicator_selector:theme_selected')
    $(event.target).addClass('active')

  onClose: ->
    @stopListening()
    @closeSubViews()
