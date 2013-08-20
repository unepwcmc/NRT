mongoose = require('mongoose')

visualisationSchema = mongoose.Schema(
  data: mongoose.Schema.Types.Mixed
  section: String
  indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
  type: String
)

visualisationSchema.statics.findFatVisualisation = (params, callback) ->
  Visualisation
    .findOne(params)
    .populate('indicator')
    .exec( (err, narrative) ->
      if err?
        callback(err)

      callback(null, narrative)
    )

Visualisation = mongoose.model('Visualisation', visualisationSchema)

module.exports = {
  schema: visualisationSchema,
  model: Visualisation
}
