#
# * GET home page.
# 
markdown = require( "markdown" ).markdown
fs = require( "fs" )

exports.about = (req, res) ->
  aboutMarkdown = fs.readFileSync("#{process.cwd()}/lib/about.md", 'UTF8')
  aboutHTML = markdown.toHTML(aboutMarkdown)
  res.render "about",
    aboutHTML: aboutHTML
    title: "Welcome to the NRT"

exports.architecture = (req, res) ->
  res.render "help/architecture",
    title: "Welcome to the NRT"
