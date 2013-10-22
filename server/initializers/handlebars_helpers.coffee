hbs = require('express-hbs')

hbs.registerHelper('css-classify', (text) ->
  if text?
    classifiedText = text.toLowerCase()
    classifiedText = classifiedText.replace(/\ /g, '-')
    return classifiedText
)
