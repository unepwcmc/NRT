Handlebars = require('handlebars')

module.exports = (partialName, object) ->
  Handlebars.compile("""
    {{> #{partialName} object}}
  """)(object:object)