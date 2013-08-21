###
  Register Handlebars helpers
###

# This uses the 'marked' library from https://github.com/chjj/marked
Handlebars.registerHelper "markup", (optionalValue) ->
  if marked?
    $(marked(this.content)).html()

Handlebars.registerHelper "selectedIfEqual", (value1, value2) ->
  if (value1 == value2) then 'selected' else ''
