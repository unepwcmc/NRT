require("coffee-script");
var app = require('../app.coffee'),
    port = process.env.PORT || 3000;

app.start(port, function (err) {
  if (err) { 
    console.error(err);
    process.exit(1);
  } else {
    console.log("Express server listening on port " + port);
  }
});
