window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.PermissionsView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['permissions.hbs']

  events:
    'click .change-owner': 'chooseNewOwner'

  className: 'permissions-view'

  initialize: (options) ->
    @ownable = options.ownable
    @user = options.user
    @listenTo(@ownable, 'change:owner', @render)

    @render()

  chooseNewOwner: =>
    @chooseUserView = new Backbone.Views.ChooseUserView()
    @$el.append(@chooseUserView.el)

    $(@chooseUserView.el).slideDown()
    $('.change-owner').hide()

    @chooseUserView.on('userSelected', @setOwner)
    @chooseUserView.on('close', @render)

    @chooseUserView.render()

  setOwner: (owner) =>
    @ownable.set('owner', owner)
    @ownable.save(
      error: (xhr, errorState, errorMessage) ->
        console.log errorMessage
        alert('Unable to save new owner')
    )

  render: =>
    owner = @ownable.get('owner')
    ownerJSON = owner? && owner.toJSON()

    isEditable = @user?

    @$el.html(@template(
      ownableName: @ownable.constructor.name
      owner: ownerJSON
      isEditable: isEditable
    ))

    @attachSubViews()

    return @

  onClose: ->
    @stopListening()
    @chooseUserView.close() if @chooseUserView?
