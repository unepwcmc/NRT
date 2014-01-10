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

    @listenTo(Backbone, 'indicator_selector:theme_selected', @deactivateAllIndicators)

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
