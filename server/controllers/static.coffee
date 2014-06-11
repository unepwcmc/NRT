#
# * GET home page.
#
markdown = require( "markdown" ).markdown
fs = require( "fs" )

exports.about = (req, res) ->
  res.render "about",
    title: "Welcome to the NRT"

exports.architecture = (req, res) ->
  res.render "help/architecture",
    title: "NRT System Architecture"

exports.partners = (req, res) ->
  res.render "help/partners",
    title: "NRT Partners"

exports.importingData = (req, res) ->
  res.render "help/importingData",
    title: "Importing data to NRT"
