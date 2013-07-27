window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.VisualisationView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['visualisation.hbs']

  initialize: (options) ->
    @visualisation = options.visualisation
    @visualisation.set('data', Backbone.Faker.Reports.createFakeData())

  render: =>
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      visualisation: @visualisation
    ))
    @renderSubViews()

    return @

  onClose: ->
    @closeSubViews()
