addSubView: (viewName, cacheKey, options) ->
  viewOptions = options.hash || {}

  @subViews ||= {}

  if @subViews[cacheKey]?
    view = @subView[cacheKey]
  else
    View = Backbone.Views[viewName]
    view = new View(viewOptions)

    @subViews ||= {}
    @subView[cacheKey] = view

  return @generateSubViewPlaceholderTag(view)

# How do we clear out views which don't need to be on the page any more
