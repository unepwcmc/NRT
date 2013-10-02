window.Backbone.Models || = {}

class window.Backbone.Models.User extends Backbone.RelationalModel
  idAttribute: '_id'

Backbone.Models.User.setup()
