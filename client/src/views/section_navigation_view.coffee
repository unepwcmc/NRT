window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionNavigationView extends Backbone.View
  template: Handlebars.templates['section_navigation.hbs']
  className: 'section-navigation'

  initialize: (options) ->
    @sections = options.sections

    @listenTo @sections, 'add', @render
    @listenTo @sections, 'reset', @render
    @render()

  render: ->
    @$el.html(@template(
      sections: @sections.map (section)->
        title = section.get('title')
        if section.get('indicator')?
          title = section.get('indicator').get('title')
  
        return {
          cid: section.cid
          _id: section.get('_id')
          title: title
        }
    ))
    @$el.find('ol').sortable().bind('sortupdate', @updateOrder)
    return @

  updateOrder: (event) =>
    cids = @getOrderedCids()
    @sections.reorderByCid(cids)

  getOrderedCids: ->
    orderedCids = []
    @$el.find('li').each((index, li)->
      orderedCids.push($(li).attr('data-section-cid'))
    )
    return orderedCids

  onClose: ->
    @stopListening()
