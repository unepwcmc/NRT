fs = require('fs')
#
# * Set users locale
#
exports.index = (req, res) ->
  res.header('Cache-Control', 'no-store')

  if req.params.locale?
    res.cookie('nrt_locale', req.params.locale)
    res.redirect('back')

exports.redirect = (req, res) ->
  enLocale = JSON.parse(
    fs.readFileSync("#{process.cwd()}/public/locales/en.json", 'UTF8')
  )

  res.send(enLocale)
