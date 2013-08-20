window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.NarrativeCollection extends Backbone.Collection
  model: Backbone.Models.Narrative

  url: "/api/narratives"
  
