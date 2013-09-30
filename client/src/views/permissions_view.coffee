window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.PermissionsView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['permissions.hbs']

  events:
    '.change-owner': 'changeOwner'

  initialize: (options) ->
    @permissions = options.permissions || {}
    @render()

  changeOwner: ->

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
    
