window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.DpsirFilterView extends Backbone.View
  events:
    'click li': 'reloadPageWithNewFilters'

  initialize: (options) ->
    @setElement(options.el)

  reloadPageWithNewFilters: (event) ->
    params = {dpsir: @updateParams(event)}
    window.location = "/?#{$.param(params)}"

  updateParams: (event) ->
    $(event.target).toggleClass('active')
    return @getParameters()

  dpsirNameMap:
    D: 'driver'
    P: 'pressure'
    S: 'state'
    I: 'impact'
    R: 'response'

  getParameters: ->
    params = {}

    elements = @$el.find('li')
    for element in elements
      $element = $(element)

      type = @dpsirNameMap[$element.text()]
      params[type] = $element.hasClass('active')

    return params

  onClose: ->
    
