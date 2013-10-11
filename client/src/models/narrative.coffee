window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.RelationalModel
  idAttribute: '_id'

  defaults:
    content: ""
    title: "title"

  urlRoot: "/api/narratives"

  getPage: ->
    @get('section').getPage()

#For backbone relational
Backbone.Models.Narrative.setup()
