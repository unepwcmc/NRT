#moment = require('moment')
mongoose = require('mongoose')

reportSchema = mongoose.Schema(
  title: String
  brief: String
  introduction: String
  conclusion: String
  period: String
  sections: [{type: mongoose.Schema.Types.ObjectId, ref: 'Section'}]
)

reportSchema.statics.findFatReport = (id, callback) ->
  Section = require('./section.coffee').model

  Report
    .findOne(_id: id)
    .exec( (err, report) ->
      if err?
        return callback(err, null)

      Section
        .find({_id: {$in: report.sections}})
        .populate('indicator narrative visualisation')
        .exec( (err, sections) ->
          result = report.toObject()
          result.sections = sections

          callback(null, result)
        )
    )

Report = mongoose.model('Report', reportSchema)

module.exports = {
  schema: reportSchema
  model: Report
}
