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

hbs.registerHelper('themeIconClass', (title) ->
  themeIconMap =
    "Air Quality": "cloud"
    "Biodiversity": "bar-chart"
    "Water": "beaker"
    "Productive Natural Resources": "globe"
    "Environmental Awareness": "picture"

  return themeIconMap[title]
)

hbs.registerHelper('newestHeadline', (array = []) ->
  headline = array[0]
  if headline?
    return headline.year
)

hbs.registerHelper('oldestHeadline', (array = []) ->
  headline = array[array.length - 1]
  if headline?
    return headline.year
)
