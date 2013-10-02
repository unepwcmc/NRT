window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.PermissionsView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['permissions.hbs']

  events:
    'click .change-owner': 'chooseNewOwner'

  initialize: (options) ->
    @ownable = options.ownable
    @listenTo(@ownable, 'change:owner', @render)

    @render()

  chooseNewOwner: =>
    @chooseUserView = new Backbone.Views.ChooseUserView()
    @chooseUserView.setElement(@$el.find('#choose-owner-view')[0])
    @chooseUserView.on('userSelected', @setOwner)
    @chooseUserView.render()

  setOwner: (owner) =>
    @ownable.set('owner', owner)
    @ownable.save(
      error: (xhr, errorState, errorMessage) ->
        console.log errorMessage
        alert('Unable to save new owner')
    )

  render: =>
    @closeSubViews()

    owner = @ownable.get('owner')
    ownerJSON = owner? && owner.toJSON()

    @$el.html(@template(
      owner: ownerJSON
    ))

    @renderSubViews()

    return @

  onClose: ->
    @stopListening()
    @chooseUserView.close() if @chooseUserView?
