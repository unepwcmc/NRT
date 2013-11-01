window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ChooseUserView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['choose_user.hbs']

  events:
    'keyup input': 'updateSearch'
    'click .choose-user': 'chooseUser'
    'click .close': 'hideView'

  className: 'dialog'
 
  initialize: (options) ->
    @users = new Backbone.Collections.UserCollection()
    @results = new Backbone.Collections.UserCollection()

  render: ->
    @$el.html(@template(
      thisView: @
      results: @results
    ))
    @attachSubViews()
    @listenToSearchSubViewSelectEvent()

    return @

  listenToSearchSubViewSelectEvent: ->
    for viewKey, subView of @subViews
      subView.on('select', @setSelectedUser)

  setSelectedUser: (user) =>
    @selectedUser = user
    @$el.find('input').val(@selectedUser.get('name'))
    @hideSubView()

  hideSubView: ->
    for viewKey, subView of @subViews
      subView.$el.hide()

  showSubView: ->
    for viewKey, subView of @subViews
      subView.$el.show()

  chooseUser: =>
    @trigger('userSelected', @selectedUser)
    @close()

  updateSearch: =>
    searchTerm = $('input').val()

    return @hideSubView() if searchTerm.length is 0

    @users.search(searchTerm)
    .done(@showSearchResults)
    .fail((err) =>
      console.log "Unable to load user search for '#{searchTerm}'"
      console.log err
    )

  showSearchResults: (results) =>
    @results.reset(results)
    @showSubView()

  onClose: ->
    @closeSubViews()

  hideView: =>
    @$el.slideUp(=>
      @trigger('close')
      @close()
    )
