#
# * GET home page.
# 
exports.about = (req, res) ->
  res.render "about",
    title: "Express"
