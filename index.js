require('coffee-script');
var app = require('./app');

var port = process.env.PORT || 3002;
server = app.start(port, function(err) {
  if (err) {
    console.error(err);
    process.exit(1);
  } else {
    console.log("Express server listening on port " + port);
  }
});
