window.Backbone ||= {}
window.Backbone.Mixins ||= {}

window.Backbone.Mixins.EditModeMixin =
  isEditable: ->
    if typeof @getPage is 'function'
      page = @getPage()
      if page? && page.get('is_draft')?
        return page.get('is_draft')

    return true
