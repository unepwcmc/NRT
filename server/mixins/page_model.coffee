async = require('async')
Q = require('q')
Page = require('../models/page').model

module.exports = {
  getDraftPage: ->
    deferred = Q.defer()

    Q.nsend(
      Page.findOne({parent_id: @_id, is_draft: true}), 'exec'
    ).then( (page) =>
      if page?
        deferred.resolve(page)
      else
        @getPage().then( (nonDraftPage) ->
          nonDraftPage.createDraftClone()
        ).then( (clonedPage) ->
          Q.nsend(
            Page, 'findFatModel', clonedPage._id
          )
        ).then( (fatPage) ->
          deferred.resolve(fatPage)
        )
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  getPage: ->
    deferred = Q.defer()

    Q.nsend(
      Page.findOne(parent_id: @_id), 'exec'
    ).then( (page) =>
      if page?
        deferred.resolve(page)
      else
        Page.create(
          parent_id: @_id
          parent_type: @constructor.modelName
        , (err, page) ->
          if err?
            return deferred.reject(err)

          deferred.resolve(
            page
          )
        )
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  getFatPage: ->
    deferred = Q.defer()

    @getPage().then( (page) ->
      Q.nsend(
        Page, 'findFatModel', page._id
      )
    ).then( (fatPage) ->
      deferred.resolve(fatPage)
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  toObjectWithNestedPage: (options = {draft: false}) ->
    deferred = Q.defer()

    getMethod = @getFatPage
    getMethod = @getDraftPage if options.draft

    getMethod.call(@).then( (page) =>
      object = @toObject()
      object.page = page

      deferred.resolve(object)
    ).fail( (err) ->
      console.error err
      deferred.reject(err)
    )

    return deferred.promise
}
