exports.login = (req, res) ->
  res.render("sessions/login", {errors: req.flash('error')})

exports.logout = (req, res) ->
  req.logout()
  res.redirect('/')

exports.loginSuccess = (req, res) ->
  res.redirect('/')
