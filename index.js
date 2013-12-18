require('coffee-script');
var app = require('./app');

server = app.start(function(err) {
  if (err) {
    console.error(err);
    process.exit(1);
  } else {
    console.log("Express server listening on port " + server.address().port);
  }
});
