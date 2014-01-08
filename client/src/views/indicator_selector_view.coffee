window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator_selector.hbs']
  className: 'modal indicator-selector'

  events:
    "click .close": "close"

  initialize: (options = {}) ->
    @currentIndicator  = options.currentIndicator
    @indicators = new Backbone.Collections.IndicatorCollection([], withData: true)
    @themes = new Backbone.Collections.ThemeCollection()

    @results = new Backbone.Collections.IndicatorCollection()
    @listenTo(@results, 'reset', @render)

    @populateCollections()
      .then( =>
        @results.reset(@indicators.models)
      ).fail( (err) ->
        console.error "Error populating collections"
        console.error err
      )

  render: =>
    @stopListeningToSubViews()
    $('body').addClass('stop-scrolling')

    @$el.html(@template(
      thisView: @
      currentIndicator: @currentIndicator
      indicators: @results.models
      themes: @themes.models
    ))
    @attachSubViews()

    @listenToSubViewEvents()

    return @

  populateCollections: ->
    @indicators.fetch().then(=>
      @themes.fetch()
    )

  filterByTheme: (theme) =>
    @results.reset(@indicators.filterByTheme(theme))

  listenToSubViewEvents: ->
    for key, subView of @subViews
      if /theme-filter-.*/.test key
        @listenTo(subView, 'selected', @filterByTheme)

      if /indicator-/.test key
        @listenTo(subView, 'indicatorSelected', @triggerIndicatorSelected)

  stopListeningToSubViews: ->
    for key, subView of @subViews
      @stopListening(subView)

  triggerIndicatorSelected: (indicator) =>
    @trigger('indicatorSelected', indicator)

  onClose: ->
    $('body').removeClass('stop-scrolling')

    @stopListening()
    @closeSubViews()
