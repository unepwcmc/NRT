window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.RelationalModel
  defaults:
    content: ""
    title: "title"
    editing: false

  url: ->
    if @get('id')
      "/api/narrative/#{@get('id')}"
    else
      "/api/narrative"

#For backbone relational
Backbone.Models.Narrative.setup()
