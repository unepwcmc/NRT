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

      $newStatus.css display: 'block'

      $oldStatus.animate width: '0px'
      $newStatus.animate width: '120px'
      
      $oldStatus.css display: 'none'

      @statusVisible = toStatus
      @startDecay()

    else  
      @$el.find('.save-status').css(
        width: '0px'
        display: 'none'
      )
      $status = @$el.find(".save-status.#{toStatus}")
      $status.css display: 'block'
      $status.animate width:'120px'
      @statusVisible = toStatus
      @startDecay()


  startDecay: =>
    clearTimeout @statusDecay
    if @statusVisible == 'saved'
      @statusDecay = setTimeout @clearStatus, 3000

  clearStatus: =>
    @$el.find('.save-status').animate(
      width: '0px'
      display: 'none'
    ) 