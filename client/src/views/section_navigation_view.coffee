window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionNavigationView extends Backbone.View
  template: Handlebars.templates['section_navigation.hbs']
  className: 'section-navigation'

  initialize: (options) ->
    @sections = options.sections

    @listenTo @sections, 'add', @render
    @render()

  render: ->
    console.log 'rendered'
    @$el.html(@template(
      sections: @sections.map (s)->
        id: s.get('id')
        title: s.get('title')
    ))
    return @

  onClose: ->
    @stopListening()    
