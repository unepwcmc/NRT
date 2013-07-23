window.Backbone.Models || = {}

class window.Backbone.Models.Narrative extends Backbone.Model
  defaults:
    content: "Narrative goes here."
    title: "title"
    editing: true

  url: "/api/narrative"
