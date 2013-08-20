window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.RelationalModel
  idAttribute: '_id'

  defaults:
    content: ""
    title: "title"
    editing: false

  urlRoot: "/api/narratives"

#For backbone relational
Backbone.Models.Narrative.setup()
