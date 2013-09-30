window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.PermissionsView extends Backbone.NestingView
  template: Handlebars.templates['permissions.hbs']

  initialize: (options) ->
    @permissions = options.permissions || {}
    @render()

  render: ->
    owner = @permissions.owner
    ownerJSON = owner? && owner.toJSON()

    @$el.html(@template(
      owner: ownerJSON
    ))
    return @

  onClose: ->
    
