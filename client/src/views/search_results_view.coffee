window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SearchResultsView extends Backbone.View
  template: Handlebars.templates['search_results.hbs']

  tagName: 'ul'
  
  className: 'search-results'

  events:
    'click li': 'selectUser'

  initialize: (options) ->
    @users = options.collection
    @listenTo(@users, 'reset', @render)
    @render()

  selectUser: (event) =>
    id = $(event.target).attr('data-user-id')
    user = @users.get(id)

    if user?
      @trigger('select', user)

  render: ->
    @$el.html(@template(users: @users.toJSON()))
    return @

  onClose: ->
    @stopListening()
