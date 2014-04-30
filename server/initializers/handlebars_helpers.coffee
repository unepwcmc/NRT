hbs = require('express-hbs')
HeadlineService = require ('../lib/services/headline')
Permissions = require ('../lib/services/permissions')

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

hbs.registerHelper('consoleLog', (thing) ->
  console.log thing
)

hbs.registerHelper('ifFeatureEnabled', (featureName, options) ->
  features = require('./config').get('features')

  if features[featureName]
    options.fn(this)
)

hbs.registerHelper('ifCanEdit', (user, options) ->
  if (new Permissions(user)).canEdit()
    options.fn(this)
)
