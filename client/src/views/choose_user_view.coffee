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
    @closeSubViews()
    @$el.html(@template(
      thisView: @
      results: @results
    ))
    @renderSubViews()
    @listenToSearchSubViewSelectEvent()

    return @

  listenToSearchSubViewSelectEvent: ->
    for subView in @subViews
      subView.on('select', @setSelectedUser)

  setSelectedUser: (user) =>
    @selectedUser = user
    @$el.find('input').val(@selectedUser.get('name'))
    @hideSubView()

  hideSubView: ->
    if @subViews?
      @subViews[0].$el.hide()

  showSubView: ->
    if @subViews?
      @subViews[0].$el.show()

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
      @close()
    )
