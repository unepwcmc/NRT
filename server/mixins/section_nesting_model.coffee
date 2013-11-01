async = require('async')
Narrative = require('../models/narrative.coffee').model
Visualisation = require('../models/visualisation.coffee').model
Q = require('q')

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
            _.extend(section.toObject(), fatChildren)
            cb(null, section)
          ).fail( (err) ->
            cb(err)
          )

      async.map(model.sections, populateChildren, (err, sections) ->
        model = model.toObject()
        model.sections = sections
        callback(null, model)
      )

    ).fail( (err) ->
      console.log "error populating model"
      return callback(err, null)
    )
}
