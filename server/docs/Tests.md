### Tests

#### Server

In the `server/test/` folder (unsurprisingly). We're using mocha with the qunit
interface and using the chai assertion syntax.

Run them with

`npm test`

##### Using promises in tests

Promises are used through-out the application to prevent callback pyramids. One
thing to note when using them, particularly in tests, is that you must specify a
catch handler as well as success for every deferred, or your application will
silently fail. In tests, you can usually just handle do this by passing mocha's
`done` function to catch, e.g:

```coffeescript
test('somePromiseFunction', (done) ->
  somePromiseFunction.then(->
    # some assertions
    done()
  ).catch(done) # This will call done with an error as first argument, which triggers mocha's error state
)
```

#### Client

##### Running 'em

Ensure you've run `grunt` to compile the tests, and fire up the app, then
visit [http://localhost:3000/tests](http://localhost:3000/tests)

##### Writing 'em

The tests are written in mocha, using the qunit syntax with chai for
asserts. Write tests in Coffeescript in the `client/test/src/` folder and
compile them with `grunt`.
