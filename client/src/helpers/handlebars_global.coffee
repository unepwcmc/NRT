###
  Register Handlebars helpers
###

# This uses the 'marked' library from https://github.com/chjj/marked
Handlebars.registerHelper "markup", (optionalValue) ->
  if marked?
    marked.setOptions(breaks: true)
    return new Handlebars.SafeString(marked(this.content))

Handlebars.registerHelper "selectedIfEqual", (value1, value2) ->
  if (value1 == value2) then 'selected' else ''

Handlebars.registerHelper "t", (key) ->
  return new Handlebars.SafeString(i18n.t(key))

Handlebars.registerHelper 'css-classify', (text) ->
  if text?
    classifiedText = text.toLowerCase()
    classifiedText = classifiedText.replace(/\ /g, '-')
    return new Handlebars.SafeString(classifiedText)
