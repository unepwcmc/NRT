window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator.hbs']

  events:
    'click .add-indicator-section': 'addSection'

  initialize: (options) ->
    @indicator = options.indicator
    @page      = @indicator.get('page')
    @draftMode = @page.get('is_draft') || false
    @listenTo(@page.get('sections'), 'add', @render)
    @render()

  render: ->
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      sections: @page.get('sections').models
    ))

    @renderSubViews()
    return @

  addSection: =>
    if @indicator.get('_id')?
      @page.get('sections').add({})
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
