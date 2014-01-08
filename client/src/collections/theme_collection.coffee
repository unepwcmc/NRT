window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.ThemeCollection extends Backbone.Collection
  model: Backbone.Models.Theme

  url: '/api/themes'
