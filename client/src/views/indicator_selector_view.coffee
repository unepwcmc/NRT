window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator_selector.hbs']
  className: 'modal indicator-selector'

  events:
    "click .close": "close"
    "click .clear-search": "clearSearch"
    "keyup input": "filterByTitle"

  initialize: (options = {}) ->
    @currentIndicator  = options.currentIndicator
    @indicators = new Backbone.Collections.IndicatorCollection([], withData: true)

    @results = new Backbone.Collections.IndicatorCollection()
    @textFilteredIndicators = new Backbone.Collections.IndicatorCollection()

    @listenTo(Backbone, 'indicator_selector:theme_selected', @filterByTheme)
    @listenTo(Backbone, 'indicator_selector:indicator_selected', @triggerIndicatorSelected)

    @populateCollections()
      .then( =>
        @results.reset(@indicators.models)
        @textFilteredIndicators.reset(@indicators.models)
      ).fail( (err) ->
        console.error "Error populating collections"
        console.error err
      )

    @render()

    @listenTo(@subViews['data-origin-selector'], 'selected', @filterByType)

  render: =>
    $('body').addClass('stop-scrolling')

    @$el.html(@template(
      thisView: @
      currentIndicator: @currentIndicator
      indicators: @results
      textFilteredIndicators: @textFilteredIndicators
    ))
    @attachSubViews()

    return @

  populateCollections: ->
    @indicators.fetch()

  filterByType: (type) ->
    @filter ||= {}
    @filter.type = type

    @filterIndicators()

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
    results = @indicators.filterByType(@filter.type)
    @results.set(results)

    results = @results.filterByTitle(@filter.searchTerm)
    @textFilteredIndicators.reset(results)
    @results.set(results)

    results = @results.filterByTheme(@filter.theme)
    @results.reset(results)

  triggerIndicatorSelected: (indicator) =>
    @trigger('indicatorSelected', indicator)

  clearSearch: ->
    @$el.find('input').val('')
    @filter.searchTerm = ""
    @filterIndicators()

  onClose: ->
    $('body').removeClass('stop-scrolling')

    @stopListening()
    @closeSubViews()
