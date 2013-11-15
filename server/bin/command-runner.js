
exports.printProcessMessages = function(theProcess) {
  theProcess.stdout.on('data', function (data) {
    console.log(data.toString());
  });

  theProcess.stderr.on('data', function (data) {
    console.log('ERROR: ' + data);
  });
};

exports.usingWindows = function() {
  return new RegExp("^win").test(process.platform);
};

exports.spawn = function(processName, args) {
  var spawn = require('child_process').spawn;
  var childProcess;

  if (usingWindows()) {
    args = ["/c", processName].concat(args || []);
    processName = 'cmd';
  }

  childProcess = spawn(processName, args);
  printProcessMessages(childProcess);

  return childProcess;
};

