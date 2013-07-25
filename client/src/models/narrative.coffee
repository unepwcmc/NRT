window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.RelationalModel
  defaults:
    content: ""
    title: "title"
    editing: true

  url: "/api/narrative"
