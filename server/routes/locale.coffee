#
# * Set users locale
#
exports.index = (req, res) ->
  if req.query.locale?
    res.cookie('nrt_locale', req.query.locale)
    res.redirect('back')
