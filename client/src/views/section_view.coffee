window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.SectionView extends Backbone.Diorama.NestingView
  template: Handlebars.templates['section.hbs']
  tagName: 'section'
  className: 'section-view'

  events:
    "click .add-title": "startTitleEdit"
    "click .choose-indicator": "chooseIndicator"
    "click .add-narrative": "addNarrative"
    "click .add-visualisation": "addVisualisation"

  initialize: (options) ->
    @section = options.section
    @section.bind('change', @render)

  render: =>
    @closeSubViews()
    noContent = !@section.get('narrative')? and !@section.get('visualisation')?

    if @section.get('indicator')?
      sectionIndicatorJSON = @section.get('indicator').toJSON()
    @$el.html(@template(
      thisView: @
      section: @section.toJSON()
      sectionIndicator: sectionIndicatorJSON
      sectionModel: @section
      noContent: noContent
      noTitleOrIndicator: !@section.hasTitleOrIndicator()
      narrative: @section.get('narrative')
      visualisation: @section.get('visualisation')
    ))
    @renderSubViews()
    return @

  startTitleEdit: =>
    @section.set('title', 'New Section')
    # Bit of a hack, starts the view in edit mode
    @$el.find('.section-title h2 .add-content').trigger('click')

  chooseIndicator: =>
    # TODO: Dummy method for now, just grabs a random indicator
    # Will show a search indicator view
    $.get('/api/indicators/', (data) =>
      indicatorData = data[Math.floor((Math.random()*data.length))]
      @section.set('indicator', indicatorData)
      @section.save(null, 
        error: (model, xhr, error) ->
          console.log error
          alert('Unable to save section, please reload the page')
      )
    )

  addNarrative: =>
    narrative = new Backbone.Models.Narrative(
      section_id: @section.get('id')
      editing: true
    )
    @section.set('narrative', narrative)

  addVisualisation: =>
    visualisation = new Backbone.Models.Visualisation(
      section: @section
      indicator: @section.get('indicator')
    )

    newVisualisationView = new Backbone.Views.ReportEditVisualisationView(
      visualisation: visualisation
    )
    $('body').append(newVisualisationView.render().el)
    $('body').addClass('stop-scrolling')
    ###
    @section.set('visualisation', visualisation)
    visualisation.save()
    ###

  onClose: ->
    @closeSubViews()
