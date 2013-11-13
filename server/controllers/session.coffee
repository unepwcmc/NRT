exports.login = (req, res) ->
  res.render("sessions/login")

exports.logout = (req, res) ->
  req.logout()
  res.redirect('/')

exports.loginSuccess = (req, res) ->
  res.redirect('/')
