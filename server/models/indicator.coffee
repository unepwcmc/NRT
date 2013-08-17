mongoose = require('mongoose')

indicatorSchema = mongoose.Schema(
  title: String
  description: String
)

Indicator = mongoose.model('Indicator', indicatorSchema)

module.exports = {
  schema: indicatorSchema,
  model: Indicator
}
