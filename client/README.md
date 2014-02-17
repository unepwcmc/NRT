# NRT Client Source

## Asset Compilation

Grunt is used to compile, combine and copy assets for use in the NRT
server application. In production and development it is used for
slightly different purposes.

### Development

In development, Grunt:

* concatenates Coffeescript files in to an `application.coffee` file to
  be streamed through a compilation middleware.
* compiles Handlebars templates and concatenates them in to an
  includable `templates.js` file.
* copies libraries to the server `public/` directory.

`grunt watch` should be used in development, as this does not compile
the Coffeescripts or Sass files (they are passed through a compilation
middleware) which should result in changes to these files requiring
compilation being sent faster.

### Production

Production does the above, with the addition of compiling the
Coffeescripts and Sass files. The watcher does not need to be run at all
on production, simply run `grunt` each time you pull down new code.
