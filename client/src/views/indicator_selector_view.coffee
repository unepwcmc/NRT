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
    ))
    @attachSubViews()

    return @

  populateCollections: ->
    @indicators.fetch()

  filterByTitle: (event) =>
    searchTerm = $(event.target).val()

    @filter ||= {}
    @filter.searchTerm = searchTerm

    @filterIndicators()

  filterByTheme: (theme) =>
    @filter ||= {}
    @filter.theme = theme

    @filterIndicators()

  filterIndicators: ->
    results = @indicators.filterByTheme(@filter.theme)
    @results.set(results)

    results = @results.filterByTitle(@filter.searchTerm)
    @results.reset(results)

  triggerIndicatorSelected: (indicator) =>
    @trigger('indicatorSelected', indicator)

  onClose: ->
    $('body').removeClass('stop-scrolling')

    @stopListening()
    @closeSubViews()
