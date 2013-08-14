#moment = require('moment')
mongoose = require('mongoose')
Section = require('./section.coffee').schema

reportSchema = mongoose.Schema(
  title: String
  brief: String
  introduction: String
  conclusion: String
  period: String
  sections: [Section]
)

Report = mongoose.model('Report', reportSchema)

module.exports = {
  schema: reportSchema
  model: Report
}
