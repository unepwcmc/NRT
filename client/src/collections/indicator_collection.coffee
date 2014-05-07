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

  filterByName: (name='') ->
    name = name.trim()

    regexp = new RegExp(".*#{name}.*", 'i')
    @filter( (indicator) ->
      regexp.test indicator.get('name')
    )

  filterByTheme: (theme) ->
    if theme?
      @filter( (indicator) ->
        indicator.get('theme') is theme.get(Backbone.Models.Theme::idAttribute)
      )
    else
      @models

  filterBySource: (sourceName) ->
    if sourceName?
      models = []
      @each((model) ->
        if model.get('source')?.name is sourceName
          models.push model
      )
      return models
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

