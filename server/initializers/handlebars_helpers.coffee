hbs = require('express-hbs')

hbs.registerHelper('css-classify', (text) ->
  if text?
    classifiedText = text.toLowerCase()
    classifiedText = classifiedText.replace(/\ /g, '-')
    return classifiedText
)

hbs.registerHelper('truncate', (text, length) ->
  if text? and text.length > length
    text = "#{text.substring(0,length)}..."

  return text
)
