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

  # Make ID object consistent
  if typeof id == 'object' && id.constructor.name != "ObjectID"
    id = id._id

  Report
    .findOne(_id: id)
    .populate('sections.indicator')
    .exec( (err, report) ->
      if err?
        console.log "error populating report"
        return callback(err, null)

      report = report.toObject()
      fetchResultFunctions = []
      for theSection, theIndex in report.sections
        (->
          index = theIndex
          section = theSection
          fetchResultFunctions.push (callback) ->
            Narrative.findOne({section: section._id}, (err, narrative) ->
              return callback(err) if err?

              if narrative?
                report.sections[index].narrative = narrative.toObject()

              Visualisation.findOne({section: section._id}, (err, visualisation) ->
                return callback(err) if err?

                if visualisation?
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
