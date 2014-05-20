# Development Workflow, Conventions and Tips

## Tabs (nope)
No tabs please, 2 spaces in all languages (HTML, CSS, Coffeescript...)

## Line-length
80 characters

## Commit workflow
Work on feature branches, commit often with small commits with only one change
to the code. When you're ready to merge your code into the master branch,
submit a pull request and have someone else review it.

## Commenting your code
Writing small (<10 lines), well named functions is preferable to comments, but
obviously comment when your code isn't intuitive.

## Documentation

New developers will expected to be able to get the application up and running
on their development machines purely by reading the README. Doing anything in
the app workflow which isn't intuitive? Make sure it's in here.

## Testing
The application is built test-first, using TDD. New features are expected to have
test coverage. Tests are written in [Mocha](), using [Chai]() and [Sinon.js](). 
See the Tests.md README for me detail

## Service-side debugging

You can use `node-inspector` to debug the server components.

* Install and run `node-inspector`
    * `npm install -g node-inspector`
    * `node-inspector &`
* Run the server with `npm run-script debug`
* Navigate to [the debugger](http://127.0.0.1:8080/debug?port=5858) in
  your browser.

You can now check out console logs and use breakpoints (in your code
with `debugger` and in the inspector itself) inside your browser.
