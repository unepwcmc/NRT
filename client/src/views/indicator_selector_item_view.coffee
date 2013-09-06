window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorSelectorItemView extends Backbone.View
  template: Handlebars.templates['indicator_selector_item.hbs']

  tagName: 'li'

  events:
    "click .info": "selectIndicator"

  initialize: (options) ->
    @indicator = options.indicator
    @section   = options.section
    @render()

  selectIndicator: ->
    @section.set('indicator', @indicator)
    @section.save()

  render: =>
    @$el.html(@template(title: @indicator.get('title')))

  onClose: ->
     
