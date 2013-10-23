hbs = require('express-hbs')

hbs.registerHelper('css-classify', (text) ->
  if text?
    classifiedText = text.toLowerCase()
    classifiedText = classifiedText.replace(/\ /g, '-')
    return classifiedText
)

hbs.registerHelper('truncate', (text) ->
  if text? and text.length > 80
    text = "#{text.substring(0,80)}..."

  return text
)
