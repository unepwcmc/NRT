window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.RelationalModel
  defaults:
    content: "Narrative goes here."
    title: "title"
    editing: true

  url: "/api/narrative"
