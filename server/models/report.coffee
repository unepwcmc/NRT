mongoose = require('mongoose')
Section = require('./section.coffee').schema
async = require('async')
_ = require('underscore')

sectionNestingModel = require('../mixins/section_nesting_model.coffee')
pageModel = require('../mixins/page_model.coffee')

reportSchema = mongoose.Schema(
  title: String
  brief: String
  period: String
  sections: [Section]
)

_.extend(reportSchema.statics, sectionNestingModel)
_.extend(reportSchema.methods, pageModel)

Report = mongoose.model('Report', reportSchema)

module.exports = {
  schema: reportSchema
  model: Report
}
