_ = require('underscore')
Promise = require('bluebird')
async = require('async')

class Factory
  define: (modelName, attributes) ->
    @[modelName] = (_attributes) =>
      new Promise( (resolve, reject) =>
        Model = require("../models/#{modelName.toLowerCase()}").model

        if _.isArray(_attributes)

          _attributes ||= []

          async.map(_attributes, Model.create.bind(Model), (err, models) ->
            if err?
              deffered.reject(new Error(err))

            resolve(models)
          )

        else

          _attributes ||= {}
          _attributes = _.extend(attributes, _attributes)

          Model.create(attributes, (err, model) ->
            if err?
              reject(new Error(err))

            resolve(model)
          )
      )

  defineWithCallback: (modelName, attributes) ->
    @[modelName] = (_attributes, callback) =>
      Model = require("../models/#{modelName.toLowerCase()}").model

      unless callback?
        callback = _attributes
        _attributes = undefined

      if _.isArray(_attributes)

        _attributes ||= []

        async.map(_attributes, Model.create.bind(Model), (err, models) ->
          if err?
            callback(err)

          callback(null, models)
        )

      else

        _attributes ||= {}
        _attributes = _.extend(attributes, _attributes)

        Model.create(attributes, (err, model) ->
          if err?
            callback(err)

          callback(null, model)
        )

module.exports = new Factory()
