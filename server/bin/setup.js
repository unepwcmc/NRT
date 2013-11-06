var printProcessMessages = function(theProcess) {
  theProcess.stdout.on('data', function (data) {
    console.log(data.toString());
  });

  theProcess.stderr.on('data', function (data) {
    console.log('ERROR: ' + data);
  });
};

var usingWindows = function() {
  return new RegExp("^win").test(process.platform);
};

var spawn = function(processName, args) {
  var spawn = require('child_process').spawn;
  var childProcess;

  if (usingWindows()) {
    args = ["/c", processName].concat(args);
    processName = 'cmd';
  }

  childProcess = spawn(processName, args);
  printProcessMessages(childProcess);

  return childProcess;
};

var PARENT_DIR = process.cwd() + "/../";

process.chdir(PARENT_DIR + '/client/');

console.log("##### Installing client npm libs #####");
npm_install = spawn('npm', ['install']);

npm_install.on('close', function(code) {
  if (code === 0) {

    // Compile assets
    console.log("#### Compiling assets #####");
    grunt = spawn('grunt');

    grunt.on('close', function(code) {
      if (code === 0) {
        process.chdir('../server/');

        console.log("##### Installing server npm libs #####");
        npm_install = spawn('npm', ['install']);

        npm_install.on('close', function(code) {
          if (code === 0) {
            console.error("##### Finished installing server libs #####");
            process.exit();
          } else {
            console.error("Error installing server libs");
          }
        });
      } else {
        console.error("Error compiling assets");
      }
    })
  } else {
    console.log("Error installing libs");
  }
})
