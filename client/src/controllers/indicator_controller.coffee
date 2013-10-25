window.Backbone ||= {}
window.Backbone.Controllers ||= {}


class Backbone.Controllers.IndicatorController extends Backbone.Diorama.Controller
  constructor: (indicatorAttributes) ->
    indicator = new Backbone.Models.Indicator indicatorAttributes
    indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

    indicatorView.render()
    $('.main-content').prepend(indicatorView.el)

    if indicator.get('page').get('is_draft')
      permissionsView = new Backbone.Views.PermissionsView(
        ownable: indicator
      )

      $('.content-sidebar').prepend(permissionsView.el)

      $('.score').click(->
        view = new Backbone.Views.SelectHeadlineDateView(
          indicator: indicator
          page: indicator.get('page')
        )
        $('.score').parent().append(view.el)
      )

