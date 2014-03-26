window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.IndicatorCollection extends Backbone.Collection
  model: Backbone.Models.Indicator

  initialize: (models, options) ->
    @withData = true if options? and options.withData?

  url: ->
    url = "/api/indicators"
    if @withData? and @withData
      url += "?withData=true"
    url

  filterByTitle: (title='') ->
    title = title.trim()

    regexp = new RegExp(".*#{title}.*", 'i')
    @filter( (indicator) ->
      regexp.test indicator.get('title')
    )

  filterByTheme: (theme) ->
    if theme?
      @filter( (indicator) ->
        indicator.get('theme') is theme.get(Backbone.Models.Theme::idAttribute)
      )
    else
      @models
  
  filterByType: (type) ->
    if type?
      @where(type: type)
    else
      @models

  getSources: ->
    sources = []
    @each((model) ->
      source = model.get('source')
      sources.push(source) if source?
    )
    return _.uniq(sources, false, (source)->
      source.name
    )

