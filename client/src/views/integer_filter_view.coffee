window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IntegerFilterView extends Backbone.View
  template: Handlebars.templates['integer_filter.hbs']

  initialize: (options) ->
    @fieldAttributes = options.attributes
    @visualisation = options.visualisation
    @listenTo @visualisation, 'change:data', @render
    @render()

  render: ->
    if @visualisation.get('data')
      min = @getMinValue()
      max = @getMaxValue()
      @$el.html(@template(
        name: @fieldAttributes.name
        min: min
        max: max
        minOptions: @buildOptionsRange(min,max,min)
        maxOptions: @buildOptionsRange(min,max,max)
      ))
    else
      @visualisation.getIndicatorData()

    return @

  getMinValue: ->
    @visualisation.get('data').bounds[@fieldAttributes.name].min

  getMaxValue: ->
    @visualisation.get('data').bounds[@fieldAttributes.name].max

  buildOptionsRange: (min, max, selected) ->
    options = []
    for value in [min..max]
      isSelected = if value == selected then 'selected' else ''
      options.push(value: value, selected: isSelected)
    return options

  onClose: ->
    @stopListening
