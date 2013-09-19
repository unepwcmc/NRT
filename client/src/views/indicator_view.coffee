window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator.hbs']

  events:
    'click .add-indicator-section': 'addSection'

  initialize: (options) ->
    @indicator = options.indicator
    @listenTo(@indicator.get('sections'), 'add', @render)
    @render()

  render: ->
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      sections: @indicator.get('sections').models
    ))

    @renderSubViews()
    return @

  addSection: =>
    if @indicator.get('_id')?
      @indicator.get('sections').add({})
      @render()
    else
      @indicator.save(null,
        success: @addSection
        error: (err) ->
          console.log err
          alert('Unable to save indicator, please try again')
      )

  onClose: ->
    @stopListening()
    @closeSubViews()
