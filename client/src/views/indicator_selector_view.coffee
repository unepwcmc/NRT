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

    @populateCollections()
      .then(@render)
      .fail( (err) ->
        console.error "Error populating collections"
        console.error err
      )

  render: =>
    $('body').addClass('stop-scrolling')

    @$el.html(@template(
      thisView: @
      currentIndicator: @currentIndicator
      indicators: @indicators.models
      themes: @themes.models
    ))
    @attachSubViews()

    @listenToSubViewEvents()

    return @

  populateCollections: ->
    @indicators.fetch().then(=>
      @themes.fetch()
    )

  filterByTheme: =>

  listenToSubViewEvents: ->
    for key, subView of @subViews
      if /theme-filter-.*/.test key
        @listenTo(subView, 'selected', @filterByTheme)

      if /indicator-/.test key
        @listenTo(subView, 'indicatorSelected', @triggerIndicatorSelected)

  triggerIndicatorSelected: (indicator) =>
    @trigger('indicatorSelected', indicator)

  onClose: ->
    $('body').removeClass('stop-scrolling')

    @stopListening()
    @closeSubViews()
