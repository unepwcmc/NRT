# 
# Register Handlebars helpers
# 

# This uses the 'marked' library from https://github.com/chjj/marked

Handlebars.registerHelper "markup", (optionalValue) ->
  $(marked(this.content)).html()