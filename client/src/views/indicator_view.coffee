window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator.hbs']

  events:
    'click .add-section button': 'addSection'

  initialize: (options) ->
    @indicator = options.indicator
    @page      = @indicator.get('page')
    @listenTo(@page.get('sections'), 'add', @render)
    @render()

  render: ->
    @$el.html(@template(
      thisView: @
      sections: @page.get('sections').models
      indicator: @indicator
      isEditable: @page.get('is_draft')
    ))
    @attachSubViews()

    return @

  addSection: =>
    if @indicator.get('_id')?
      @page.get('sections').add({})
      @page.save(
        success: @render
        error: (model, xhr, options) ->
          console.log xhr
          alert('Unable to save section, please try again')
      )
    else
      @indicator.save(null,
        success: @addSection
        error: (model, xhr, options) ->
          console.log xhr
          alert('Unable to save indicator, please try again')
      )

  onClose: ->
    @stopListening()
    @closeSubViews()
