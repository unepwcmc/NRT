hbs = require('express-hbs')
i18n = require('i18n')

i18n.configure(
  locales:['en', 'ar']
  defaultLocale: 'ar'
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

module.exports = (app) ->
  app.use i18n.init

  app.use (req, res, next) ->
    app.set('localeIsArabic', req.locale? and req.locale == "ar")
    return next()
