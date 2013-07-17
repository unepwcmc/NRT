Browser = require('zombie')
browser = new Browser()

assert = require('chai').assert

before( ->
  @browser = new Browser();
  @browser.site = "http://localhost:3000/";
  @browser.silent = false;
  @browser.visit('/contact', done);
)

suite('basic maths')
test('zombie', ->
  @browser.visit('/contact', done);
)

#describe('contact page', function() {
#  before(function() {
#    this.server = http.createServer(app).listen(3000);
#    // initialize the browser using the same port as the test application
#    this.browser = new Browser({ site: 'http://localhost:3000' });
#  });
# 
#  // load the contact page
#  before(function(done) {
#    this.browser.visit('/contact', done);
#  });
# 
#  it('should show contact a form');
#  it('should refuse empty submissions');
#  // ...
# 
#});