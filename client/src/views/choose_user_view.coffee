window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ChooseUserView extends Backbone.View
  template: Handlebars.templates['choose_user.hbs']

  events:
    'keyup input': 'updateSearch'

  initialize: (options) ->
    @users = new Backbone.Collections.UserCollection()

  render: ->
    @$el.html(@template())
    return @

  updateSearch: =>
    searchTerm = $('input').val()
    @users.search(searchTerm).done((results) =>
      @showSearchResults(results)
    ).fail((err) =>
      console.log "Unable to load user search for '#{searchTerm}'"
      console.log err
    )

  onClose: ->
    
