mongoose = require('mongoose')
Section = require('./section.coffee').schema
async = require('async')
_ = require('underscore')
sectionNestingModel = require('../mixins/section_nesting_model.coffee')

pageSchema = mongoose.Schema(
  title: String
  parent_id: mongoose.Schema.Types.ObjectId
  parent_type: String
  sections: [mongoose.Schema(
    title: String
    type: String
    indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
  )]
)

_.extend(pageSchema.statics, sectionNestingModel)

Page = mongoose.model('Page', pageSchema)

module.exports = {
  schema: pageSchema
  model: Page
}
