window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionNavigationView extends Backbone.View
  template: Handlebars.templates['section_navigation.hbs']

  initialize: (options) ->
    @sections = options.sections
    @render()

  render: ->
    @$el.html(@template(
      sections: @sections.map (s)->
        id: s.get('id')
        title: s.get('title')
    ))
    return @

  onClose: ->
    
