mongoose = require('mongoose')
Section = require('./section.coffee').schema
async = require('async')

reportSchema = mongoose.Schema(
  title: String
  brief: String
  period: String
  sections: [Section]
)

reportSchema.statics.findFatReport = (id, callback) ->
  Section = require('./section.coffee').model
  Narrative = require('./narrative.coffee').model
  Visualisation = require('./visualisation.coffee').model

  Report
    .findOne(_id: id)
    .populate('sections.indicators')
    .exec( (err, report) ->
      if err?
        return callback(err, null)

      report = report.toObject()
      fetchResultFunctions = []
      for theSection, theIndex in report.sections
        (->
          index = theIndex
          section = theSection
          fetchResultFunctions.push (callback) ->
            Narrative.findOne({section_id: section._id}, (err, narrative) ->
              return callback(err) if err?
              report.sections[index].narrative = narrative.toObject()

              Visualisation.findOne({section_id: section._id}, (err, visualisation) ->
                return callback(err) if err?
                report.sections[index].visualisation = visualisation.toObject()
                callback(null, report)
              )
            )
        )()

      async.parallel(fetchResultFunctions, (err, results) ->
        callback(err, report)
      )
    )

Report = mongoose.model('Report', reportSchema)

module.exports = {
  schema: reportSchema
  model: Report
}
