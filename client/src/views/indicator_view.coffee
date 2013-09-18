window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.IndicatorView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['indicator.hbs']

  initialize: (options) ->
    @indicator = options.indicator
    @render()

  render: ->
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      sections: @indicator.get('sections')
    ))

    @renderSubViews()
    return @

  addSection: =>
    if @indicator.get('_id')?
      section = new Backbone.Models.Section()
      @indicator.get('sections').push(section)
    else
      @indicator.save(null,
        success: @addSection
        error: (err) ->
          console.log err
          alert('Unable to save indicator, please try again')
      )

  onClose: ->
    @closeSubViews()
