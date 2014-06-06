# Tests

## Server

In the `server/test/` folder (unsurprisingly). We're using mocha with the qunit
interface and using the chai assertion syntax.

Run them with

`npm test`

### Test types
The server tests are separated different types. `npm test` runs types of all
tests.

#### Units
Typical unit tests. These test system objects, using internal domain language.
They are small, fast to run and use mocking and stubbing extensively. Run these
and the integration tests with:

`npm run-script test-units`

#### Integration
These test the system behaviour of controller actions. They may check status
codes, and JSON responses. They may also test that methods are called (using
stubs) or that the database has been altered. HTML outputs can be tested, but
that's typically outside of the scope of the integration tests. Similarly, more
than one route should not be under test. These tests are fast, and expected to
finish inside 500ms (although the timeout remains 2000ms). Because of their
speed, these are run alongside units and will be run continuously in the TDD
red-green-refactor cycle

#### Acceptance tests
These test user features. Test names are written using language understandable
by users. Tests cover features which may cover multiple routes inside one test.
These tests typically use zombie.js as it is more expressive for describing
"user" features. They may optionally enable client javascript in zombie.js if
the behaviour under test requires it. These take longer to run and have a
higher mocha timeout to compensate. These aren't run as part of the short TDD
loop, but feature development should start with an acceptance test being
written. These are run before committing (but if not, are caught by travis)

### Using promises in tests

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

## Client

### Running 'em

Ensure you've run `grunt` to compile the tests, and fire up the app, then
visit [http://localhost:3000/tests](http://localhost:3000/tests)

### Writing 'em

The tests are written in mocha, using the qunit syntax with chai for
asserts. Write tests in Coffeescript in the `client/test/src/` folder and
compile them with `grunt`.
