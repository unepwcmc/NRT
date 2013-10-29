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
        visualisation: @visualisation
      ))
      @renderSubViews()
      return @

  getFieldData: ->
    fields = @visualisation.get('indicator').get('indicatorDefinition').fields
    fieldsWithSubViews = []

    for field, index in fields
      if Backbone.Views[@fieldTypeToSubViewName(field.type)]?
        field.subViewName = @fieldTypeToSubViewName(field.type)
        fieldsWithSubViews.push field

    return fieldsWithSubViews

  fieldTypeToSubViewName: (type)->
    upcasedType = type.charAt(0).toUpperCase() + type.slice(1)
    "#{upcasedType}FilterView"

  onClose: ->
    @stopListening()
    @closeSubViews()
