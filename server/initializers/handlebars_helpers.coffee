hbs = require('express-hbs')

hbs.registerHelper('css-classify', (text) ->
  classifiedText = text.toLowerCase()
  classifiedText = classifiedText.replace(/\ /g, '-')
  return classifiedText
)
