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
          deferred.resolve(clonedPage)
        )
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  getPage: ->
    deferred = Q.defer()

    Page.
      findOne({parent_id: @_id}).
      exec( (err, page) =>
        if err?
          return deferred.reject(err)

        if page?
          # Don't look! We didn't.
          # 🙈
          Page.findFatModel(page._id, (err, page) ->
            if err?
              return deferred.reject(err)

            deferred.resolve(page)
          )
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
      )

    return deferred.promise

  toObjectWithNestedPage: ->
    deferred = Q.defer()

    @getPage().then( (page) =>
      object = @toObject()
      object.page = page

      deferred.resolve(object)
    ).fail( (err) ->
      console.error err
      deferred.reject(err)
    )

    return deferred.promise
}
