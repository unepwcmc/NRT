_ = require('underscore')
Q = require('q')
async = require('async')

class Factory
  define: (modelName, attributes) ->
    modelName = modelName.toLowerCase()

    @[modelName] = (_attributes) ->
      deferred = Q.defer()
      Model = require("../models/#{modelName}").model

      if _attributes && _attributes.length != undefined
        _attributes ||= []

        console.log 'using multiple models'
        createFunctions = []
        for attribute in _attributes
          createFunctions.push (->
            theAttributes = attribute
            return (cb) ->
              Model.create(theAttributes, cb)
          )()

        async.parallel(
          createFunctions,
          (err, models) ->
            if err?
              deffered.reject(new Error(err))

            console.log models
            deferred.resolve(models)
        )
      else
        _attributes ||= {}
        _attributes = _.extend(attributes, _attributes)

        model = new Model(_attributes)

        model.save (err, model) ->
          if err?
            deferred.reject(new Error(err))

          deferred.resolve(model)

      return deferred.promise

module.exports = new Factory()
