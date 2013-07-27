window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.RelationalModel
  defaults:
    content: ""
    title: "title"
    editing: false

  url: "/api/narrative"
