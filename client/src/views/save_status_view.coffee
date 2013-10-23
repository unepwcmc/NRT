window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SaveStatusView extends Backbone.View
  template: Handlebars.templates['save_status.hbs']

  initialize: (options) ->
    Backbone.on 'save', @animateStatus
    @render()

  render: =>
    @$el.html(@template())
    $(".save-status-container").html(@$el)
    return @

  onClose: ->

  animateStatus: (toStatus) =>

    if toStatus == @statusVisible
      @startDecay()
      return

    else if @statusVisible?
      $oldStatus = @$el.find(".save-status.#{@statusVisible}")
      $newStatus = @$el.find(".save-status.#{toStatus}")

      $oldStatus.hide()
      $newStatus.fadeIn()

      @statusVisible = toStatus
      @startDecay()

    else
      $status = @$el.find(".save-status.#{toStatus}")
      $status.fadeIn()
      @statusVisible = toStatus
      @startDecay()


  startDecay: =>
    clearTimeout @statusDecay
    if @statusVisible == 'saved'
      @statusDecay = setTimeout @clearStatus, 3000

  clearStatus: =>
    @$el.find('.save-status').fadeOut()
