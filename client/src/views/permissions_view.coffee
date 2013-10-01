window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.PermissionsView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['permissions.hbs']

  events:
    'click .change-owner': 'changeOwner'

  initialize: (options) ->
    @permissions = options.permissions || {}
    @render()

  changeOwner: =>
    @chooseUserView = new Backbone.Views.ChooseUserView()
    @chooseUserView.setElement(@$el.find('#choose-owner-view')[0])
    @chooseUserView.render()

  render: ->
    @closeSubViews()

    owner = @permissions.owner
    ownerJSON = owner? && owner.toJSON()

    @$el.html(@template(
      owner: ownerJSON
    ))

    @renderSubViews()

    return @

  onClose: ->
    
