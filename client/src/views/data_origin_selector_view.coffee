window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.DataOriginSelectorView extends Backbone.View
  template: Handlebars.templates['data_origin_selector.hbs']
  className: 'origin'

  Origins:
    esri: 'Environment Agency - Abu Dhabi'
    worldBank: 'World Bank Database'

  events:
    'change select': 'triggerSelected'

  initialize: (options) ->
    @render()

  triggerSelected: ->
    originName = @$el.find('select').val()
    originName = undefined if originName is ""

    Backbone.trigger('indicator_selector:data_origin:selected', originName)

  render: ->
    @$el.html(@template(
      origins: @Origins
    ))

    FancySelect.fancify(@$el)

    return @

  onClose: ->
