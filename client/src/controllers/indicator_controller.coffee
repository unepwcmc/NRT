window.Backbone ||= {}
window.Backbone.Controllers ||= {}


class Backbone.Controllers.IndicatorController extends Backbone.Diorama.Controller
  constructor: (indicatorAttributes, user) ->
    indicator = new Backbone.Models.Indicator indicatorAttributes
    indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

    indicatorView.setElement($('.main-content')[0])
    indicatorView.render()

    permissionsView = new Backbone.Views.PermissionsView(
      ownable: indicator
      user: user
    )

    $('.content-sidebar').prepend(permissionsView.el)

    if indicator.get('page').get('is_draft')
      $('.score').click(->
        view = new Backbone.Views.SelectHeadlineDateView(
          indicator: indicator
          page: indicator.get('page')
        )
        $('.score').parent().append(view.el)
      )

