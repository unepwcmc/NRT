window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ThemeView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['theme.hbs']

  events:
    'click .add-theme-section': 'addSection'

  initialize: (options) ->
    @theme = options.theme
    @listenTo(@theme.get('sections'), 'add', @render)
    @render()

  render: ->
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      sections: @theme.get('sections').models
    ))

    @renderSubViews()
    return @

  addSection: =>
    if @theme.get('_id')?
      @theme.get('sections').add({})
      @render()
    else
      @theme.save(null,
        success: @addSection
        error: (err) ->
          console.log err
          alert('Unable to save theme, please try again')
      )

  onClose: ->
    @stopListening()
    @closeSubViews()

