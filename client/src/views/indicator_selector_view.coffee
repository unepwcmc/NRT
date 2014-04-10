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

    @listenTo(Backbone, 'indicator_selector:data_origin:selected', @filterBySource)

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

  filterBySource: (sourceName) ->
    @filter ||= {}
    @filter.sourceName = sourceName

    @filterIndicators()

  filterByTitle: (event) =>
    searchTerm = $(event.target).val()

    @updateClearSearchButton()

    @filter ||= {}
    @filter.searchTerm = searchTerm

    @filterIndicators()

  filterByTheme: (theme) =>
    @filter ||= {}
    @filter.theme = theme

    @filterIndicators()

  filterIndicators: ->
    results = @indicators.filterBySource(@filter.sourceName)
    @results.set(results)

    results = @results.filterByTitle(@filter.searchTerm)
    @textFilteredIndicators.reset(results)
    @results.set(results)

    results = @results.filterByTheme(@filter.theme)
    @results.reset(results)

  triggerIndicatorSelected: (indicator) =>
    @trigger('indicatorSelected', indicator)

  updateClearSearchButton: ->
    searchTerm = @$el.find('input').val()

    clearSearchBtn = @$el.find('.clear-search')
    if searchTerm.length is 0
      clearSearchBtn.hide()
    else
      clearSearchBtn.show()

  clearSearch: ->
    @$el.find('input').val('')
    @filter.searchTerm = ""
    @updateClearSearchButton()
    @filterIndicators()

  onClose: ->
    $('body').removeClass('stop-scrolling')

    @stopListening()
    @closeSubViews()
