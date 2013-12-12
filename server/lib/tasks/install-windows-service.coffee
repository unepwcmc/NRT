Service = require("node-windows").Service

# Create a new service object
svc = new Service(
  name: "NRT application"
  description: "The Nation Reporting Toolkit node.js web application"
  script: "#{__dirname}\\bin\\server.js"
)

# Listen for the "install" event, which indicates the
# process is available as a service.
svc.on "install", ->
  svc.start()

svc.install()
