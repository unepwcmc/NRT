hbs = require('express-hbs')
i18n = require('i18n')

i18n.configure(
  locales:['en', 'ar']
  defaultLocale: 'en'
  directory: __dirname + '/../public/locales'
  cookie: 'nrt_locale'
  updateFiles: false
)

hbs.registerHelper('t', () ->
  return i18n.__.apply(this, arguments)
)

hbs.registerHelper('pluralise', () ->
  return i18n.__n.apply(this, arguments)
)

addCurrentLocaleToLocales = (req, res, next) ->
  res.locals.localeIsArabic = (req.locale? and req.locale == "ar")
  next()

module.exports = (app) ->
  app.use i18n.init
  app.use addCurrentLocaleToLocales
