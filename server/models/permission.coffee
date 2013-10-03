mongoose = require('mongoose')

permissionSchema = mongoose.Schema(
  ability: String
  user: {type: mongoose.Schema.Types.ObjectId, ref: 'User'}
  permittable: {type: mongoose.Schema.Types.ObjectId}
  permittable_type: String
)

Permission = mongoose.model('Permission', permissionSchema)

module.exports = {
  model: Permission
  schema: permissionSchema
}
