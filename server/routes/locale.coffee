#
# * Set users locale
#
exports.index = (req, res) ->
  if req.params.locale?
    res.cookie('nrt_locale', req.params.locale)
    res.redirect('back')
