window.Backbone ||= {}
window.Backbone.Controllers ||= {}

class Backbone.Controllers.ThemeController extends Backbone.Diorama.Controller
  constructor: (themeAttributes) ->
    theme = new Backbone.Models.Theme themeAttributes
    themeView = new Backbone.Views.ThemeView(theme: theme)

    themeView.render()
    $('.main-content').append(themeView.el)
