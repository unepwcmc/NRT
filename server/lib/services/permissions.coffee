AppConfig = require('../../initializers/config')

module.exports = class Permissions
  constructor: (@user) ->

  canEdit: ->
    if AppConfig.get('features')?.open_access or @user?
      return true
    else
      return false
