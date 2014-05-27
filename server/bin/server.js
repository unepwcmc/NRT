require("coffee-script");
var app = require('../app.coffee');

app.start(function(err, server, port) {
  if (err) {
    console.error(err);
    process.exit(1);
  } else {
    console.log("Express server listening on port " + port);
  }
});
