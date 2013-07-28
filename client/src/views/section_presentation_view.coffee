window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionPresentationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section-presentation.hbs']
  tagName: 'section'
  className: 'section-view'

  initialize: (options) ->
    @section = options.section

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      narrative: @section.get('narrative')
      visualisation: @section.get('visualisation')
    ))
    @renderSubViews()

    return @

  addNarrative: =>
    @section.set('narrative', new Backbone.Models.Narrative())
    @render()

  onClose: ->
    @closeSubViews()
