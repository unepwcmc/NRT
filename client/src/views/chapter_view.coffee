window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.ChapterView extends Backbone.Diorama.NestingView
  tagName: 'h2'
  template: Handlebars.templates['chapter.hbs']

  initialize: (options) ->
    @chapter = options.section
    @listenTo(@chapter, 'change', @saveChapter)
    @render()

  render: ->
    @$el.html(@template(
      thisView: @
      chapter: @chapter
    ))
    @attachSubViews()
    return @

  onClose: ->
    @closeSubViews()
