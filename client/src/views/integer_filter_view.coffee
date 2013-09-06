window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IntegerFilterView extends Backbone.View
  template: Handlebars.templates['integer_filter.hbs']

  events:
    "change select": "updateFilters"

  initialize: (options) ->
    @fieldAttributes = options.attributes
    @visualisation = options.visualisation
    @listenTo @visualisation, 'change:data', @render
    @render()

  render: ->
    if @visualisation.get('data')?
      min = @getBound('min')
      filterMin = @getFilterValue('min')
      max = @getBound('max')
      filterMax = @getFilterValue('max')

      @$el.html(@template(
        name: @fieldAttributes.name
        min: min
        max: max
        minOptions: @buildOptionsRange(min,max,filterMin)
        maxOptions: @buildOptionsRange(min,max,filterMax)
      ))
    else
      @visualisation.getIndicatorData()

    return @

  getBound: (operation) ->
    @visualisation.get('data').bounds[@fieldAttributes.name][operation]

  getFilterValue: (operation)->
    value = null
    if @visualisation.get('filters')? and @visualisation.get('filters')[@fieldAttributes.name]?
      value = @visualisation.get('filters')[@fieldAttributes.name][operation]
    value ||= @getBound(operation)

  buildOptionsRange: (min, max, selected) ->
    options = []
    for value in [min..max]
      isSelected = if value == parseInt(selected, 10) then 'selected' else ''
      options.push(value: value, selected: isSelected)
    return options

  updateFilters: (event) =>
    $target = $(event.currentTarget)
    value = $target.val()
    nameComponents = $target.attr('name').split('-')
    operation = nameComponents[1]
    @visualisation.setFilterParameter(@fieldAttributes.name, operation, value)
    @visualisation.getIndicatorData()
    
  onClose: ->
    @stopListening
