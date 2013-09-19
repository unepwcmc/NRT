mongoose = require('mongoose')
Section = require('./section.coffee').schema
async = require('async')
_ = require('underscore')
sectionNestingModel = require('../mixins/section_nesting_model.coffee')

reportSchema = mongoose.Schema(
  title: String
  brief: String
  period: String
  sections: [Section]
)

_.extend(reportSchema.statics, sectionNestingModel)

Report = mongoose.model('Report', reportSchema)

module.exports = {
  schema: reportSchema
  model: Report
}
