_ = require('underscore')
Q = require('q')

class Factory
  define: (modelName, attributes) ->
    modelName = modelName.toLowerCase()

    @[modelName] = (_attributes) ->
      deferred = Q.defer()

      Model = require("../models/#{modelName}").model

      _attributes ||= {}
      model = new Model(_.extend(attributes, _attributes))

      model.save (err, model) ->
        if err?
          deferred.reject(new Error(err))

        deferred.resolve(model)

      return deferred.promise

module.exports = new Factory()
