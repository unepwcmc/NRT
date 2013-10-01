window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.UserCollection extends Backbone.Collection
  model: Backbone.Models.User
  
  url: '/api/users/'

  search: (search) ->
    deferred = $.Deferred()
    searchRegExp = new RegExp(".*#{search}.*", 'i')
    unless @length > 0
      @fetch(
        success: =>
          deferred.resolve(
            @filterModels(searchRegExp)
          )
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "Unable to fetch users:"
          console.log errorThrown
          deferred.reject(errorThrown)
      )
    else
      deferred.resolve(
        @filterModels(searchRegExp)
      )

    deferred

  filterModels: (regexp) =>
    @filter((user) ->
      regexp.test user.get('email')
    )

