mongoose = require('mongoose')
Section = require('./section.coffee').schema
async = require('async')
_ = require('underscore')
sectionNestingModel = require('../mixins/section_nesting_model.coffee')

pageSchema = mongoose.Schema(
  title: String
  brief: String
  period: String
  sections: [Section]
)

_.extend(pageSchema.statics, sectionNestingModel)

Page = mongoose.model('Page', pageSchema)

module.exports = {
  schema: pageSchema
  model: Page
}
