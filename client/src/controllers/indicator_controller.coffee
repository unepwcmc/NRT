window.Backbone ||= {}
window.Backbone.Controllers ||= {}


class Backbone.Controllers.IndicatorController extends Backbone.Diorama.Controller
  constructor: (indicatorAttributes) ->
    indicator = new Backbone.Models.Indicator indicatorAttributes
    indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

    indicatorView.render()
    $('.main-content').prepend(indicatorView.el)

    permissionsView = new Backbone.Views.PermissionsView(permissions: {})
    $('.content-sidebar').prepend(permissionsView.el)
