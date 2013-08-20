mongoose = require('mongoose')

visualisationSchema = mongoose.Schema(
  data: mongoose.Schema.Types.Mixed
  section: String
  indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
)

visualisationSchema.statics.findFatVisualisation = (id, callback) ->
  # Make ID object consistent
  if typeof id == 'object' && id.constructor.name != "ObjectID"
    id = id._id

  Visualisation
    .findOne(_id: id)
    .populate('indicator')
    .exec( (err, narrative) ->
      if err?
        callback(err)

      callback(null, narrative.toObject())
    )

Visualisation = mongoose.model('Visualisation', visualisationSchema)

module.exports = {
  schema: visualisationSchema,
  model: Visualisation
}
