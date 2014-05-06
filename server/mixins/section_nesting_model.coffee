async = require('async')
Promise = require('bluebird')
Narrative = require('../models/narrative.coffee').model
Visualisation = require('../models/visualisation.coffee').model

module.exports = {
  findFatModel: (id) ->
    # Make ID object consistent
    if typeof id == 'object' && id.constructor.name != "ObjectID"
      id = id._id

    new Promise( (resolve, reject) =>
      findPromise = @findOne(_id: id).populate('sections.indicator').exec()

      findPromise.onFulfill( (model) ->

        unless model?
          return resolve({message: "Unable to find model"}, {})

        model = model.toObject()
        fetchResultFunctions = []
        for theSection, theIndex in model.sections
          (->
            index = theIndex
            section = theSection
            fetchResultFunctions.push (callback) ->
              Narrative.findOne({section: section._id}, (err, narrative) ->
                return callback(err) if err?

                if narrative?
                  model.sections[index].narrative = narrative.toObject()

                Visualisation.findFatVisualisation({section: section._id}, (err, visualisation) ->
                  return callback(err) if err?

                  if visualisation?
                    model.sections[index].visualisation = visualisation.toObject()

                  callback(null, model)
                )
              )
          )()

        async.parallel(fetchResultFunctions, (err, results) ->
          resolve(model)
        )
      ).onReject( (err) ->
        console.log "error populating model"
        reject(err)
      )
    )
}
