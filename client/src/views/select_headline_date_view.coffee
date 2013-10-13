window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SelectHeadlineDateView extends Backbone.View
  template: Handlebars.templates['select_headline_date.hbs']

  className: 'select-modal'

  events:
    "click li": "setHeadline"
      
  initialize: (options) ->
    @indicator = options.indicator
    @page = options.page

    @getHeadlines()

    @render()

  render: ->
    @$el.html(@template(
      headlines: @headlines
    ))
    return @

  getHeadlines: ->
    $.getJSON("/api/indicators/#{@indicator.get('_id')}/headlines").done( (data)=>
      @headlines = data
      @render()
    ).fail(() ->
      console.error "error querying indicator headlines"
    )

  setHeadline: (event) =>
    $target = $(event.target)
    selectedYear = parseInt($target.attr('data-headline-year'))
    headline = _.where(@headlines, year: selectedYear)[0]

    @page.set('headline', headline)
    @page.save().done(=>
      location.reload()
    )
    @close()

  onClose: ->
    
