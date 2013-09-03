window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.VisualisationFilterView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['visualisation_filter.hbs']
  tagName: 'aside'
  className: 'filters'

  initialize: (options) ->
    @visualisation = options.visualisation
    @listenTo(@visualisation, "change", @render)
    @render()

  render: ->
    if @visualisation.get('data')?
      @closeSubViews()
      @$el.html(@template(
        thisView: @
        fields: @getFieldData()
      ))
      @renderSubViews()
      return @

  getFieldData: ->
    fields = @visualisation.get('indicator').get('indicatorDefinition').fields
    for field, index in fields
      fields[index].subViewName = @fieldTypeToSubViewName(field.type)
    return fields

  fieldTypeToSubViewName: (type)->
    upcasedType = type.charAt(0).toUpperCase() + type.slice(1)
    "#{upcasedType}FilterView"

  onClose: ->
    @stopListening()
    @closeSubViews()
