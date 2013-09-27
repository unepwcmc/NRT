async = require('async')
Q = require('q')
Page = require('../models/page').model

module.exports = {
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
          deferred.resolve(
            new Page(
              parent_id: @_id
              parent_type: @constructor.modelName
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
