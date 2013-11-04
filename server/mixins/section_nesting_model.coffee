async = require('async')
Narrative = require('../models/narrative.coffee').model
Visualisation = require('../models/visualisation.coffee').model
Q = require('q')
_ = require('underscore')

module.exports = {
  findFatModel: (id, callback) ->
    # Make ID object consistent
    if typeof id == 'object' && id.constructor.name != "ObjectID"
      id = id._id

    Q.nsend(
      @findOne(_id: id).populate('sections.indicator'),
      'exec'
    ).then( (model) ->

      unless model?
        return callback({message: "Unable to find model"}, {})

      populateChildren = (section, cb) ->
        section
          .getFatChildren()
          .then( (fatChildren) ->
            fatSection = _.extend(section.toObject(), fatChildren)
            cb(null, fatSection)
          ).fail( (err) ->
            cb(err)
          )

      async.map(model.sections, populateChildren, (err, sections) ->
        if err?
          callback(err)
        else
          model = model.toObject()
          model.sections = sections
          callback(null, model)
      )

    ).fail( (err) ->
      console.log "error populating model"
      return callback(err, null)
    )
}
