# NRT Client Source

## Asset Compilation

Grunt is used to compile, combine and copy assets for use in the NRT
server application. In production and development it is used for
slightly different purposes.

## `grunt`
Concatenates and compiles everything you need to run the application.

* concatenates Coffeescript files in to an `application.coffee`, then compiles them to javascript
* compiles Handlebars templates and concatenates them in to an includable `templates.js` file.
* concatenates and compiles SASS
* copies libraries to the server `public/` directory.

## `grunt watch`
For use in development, `grunt watch` watches your files for changes,
and concatenates them when that happens.

It differs from the above in that rather than compiling coffeescript and SASS,
it leaves simply concatenates them, then expects the coffeescript and node-sass
middlewares to perform the compilation. This leads to better performance when 
working in development.

These middlewares are disabled in production (for speed), meaning this task alone
will not work, and you must run `grunt` on it's own.
