async = require('async')
Q = require('q')
Page = require('../models/page').model

module.exports = {
  populatePageAttribute: () ->
    deferred = Q.defer()

    Page.
      findOne({parent_id: @_id}).
      exec( (err, page) =>
        if err?
          return deferred.reject(err)

        @page = page || new Page(
          parent_id: @_id
          parent_type: @constructor.modelName
        )

        deferred.resolve(@page)
      )

    return deferred.promise
}
