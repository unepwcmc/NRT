window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.RelationalModel
  defaults:
    content: ""
    title: "title"
    editing: false

  url: ->
    if @get('id')
      "/api/narratives/#{@get('id')}"
    else
      "/api/narratives"

#For backbone relational
Backbone.Models.Narrative.setup()
