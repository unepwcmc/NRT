window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator_selector.hbs']
  className: 'modal indicator-selector'

  events:
    "click .close": "close"
    "keyup input": "filterByTitle"

  initialize: (options = {}) ->
    @currentIndicator  = options.currentIndicator
    @indicators = new Backbone.Collections.IndicatorCollection([], withData: true)
    @results = new Backbone.Collections.IndicatorCollection()

    @themes = new Backbone.Collections.ThemeCollection()
    @listenTo(@themes, 'reset', @render)

    @listenTo(Backbone, 'indicator_selector:theme_selected', @filterByTheme)
    @listenTo(Backbone, 'indicator_selector:indicator_selected', @triggerIndicatorSelected)

    @populateCollections()
      .then( =>
        @results.reset(@indicators.models)
      ).fail( (err) ->
        console.error "Error populating collections"
        console.error err
      )

    @render()

  render: =>
    $('body').addClass('stop-scrolling')

    @$el.html(@template(
      thisView: @
      currentIndicator: @currentIndicator
      indicators: @results
      themes: @themes
    ))
    @attachSubViews()

    return @

  populateCollections: ->
    @indicators.fetch().then(=>
      @themes.fetch()
    )

  filterByTitle: (event) =>
    searchTerm = $(event.target).val()
    @results.reset(@indicators.filterByTitle(searchTerm))

  filterByTheme: (theme) =>
    @results.reset(@indicators.filterByTheme(theme))

  triggerIndicatorSelected: (indicator) =>
    @trigger('indicatorSelected', indicator)

  onClose: ->
    $('body').removeClass('stop-scrolling')

    @stopListening()
    @closeSubViews()
