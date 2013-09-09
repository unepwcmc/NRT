hbs = require('express-hbs')
i18n = require('i18n')

i18n.configure(
  locales:['en', 'ar']
  defaultLocale: 'en'
  directory: __dirname + '/../public/locales'
  cookie: 'nrt_locale'
  updateFiles: false
)

hbs.registerHelper('t', (text, options) ->
  translation = i18n.__(text)
  return new hbs.SafeString(translation)
)
