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
          type: section.get('type')
        }
    ))
    @$el.find('ol').sortable().bind('sortupdate', @updateOrder)
    return @

  updateOrder: (event) =>
    cids = @getOrderedCids()
    @sections.reorderByCid(cids)
    @saveReport()

  getOrderedCids: ->
    orderedCids = []
    @$el.find('li').each((index, li)->
      orderedCids.push($(li).attr('data-section-cid'))
    )
    return orderedCids

  saveReport: ->
    firstSection = @sections.at(0)
    if firstSection?
      report = firstSection.get('report')
      Backbone.trigger 'save', 'saving'
      report.save().done(
        Backbone.trigger 'save', 'saved'
      )

  onClose: ->
    @stopListening()
