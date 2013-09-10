#
# * GET home page.
# 
exports.about = (req, res) ->
  res.render "about",
    title: "Welcome to the NRT"
