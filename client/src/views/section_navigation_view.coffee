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
    @$el.html(@template(
      sections: @sections.map (section)->
        title = section.get('title')
        if section.get('indicator')?
          title = section.get('indicator').get('title')

        return {
          _id: section.get('_id')
          title: title
        }
    ))
    return @

  onClose: ->
    @stopListening()
