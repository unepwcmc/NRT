var printProcessMessages = function(process) {
  process.stdout.on('data', function (data) {
    console.log('' + data);
  });

  process.stderr.on('data', function (data) {
    console.log('ERROR: ' + data);
  });
};

var spawn = require('child_process').spawn

var PARENT_DIR = process.cwd() + "/../";

process.chdir(PARENT_DIR + '/client/');

console.log("##### Installing client npm libs #####");
// install client libs
npm_install = spawn('npm', ['install']);
printProcessMessages(npm_install);

npm_install.on('close', function(code) {
  if (code === 0) {

    // Compile assets
    console.log("#### Compiling assets #####");
    grunt = spawn('grunt');
    printProcessMessages(grunt);

    grunt.on('close', function(code) {
      if (code === 0) {
        process.chdir('../server/');

        // Install server libs
        console.log("##### Installing server npm libs #####");
        npm_install = spawn('npm', ['install']);
        printProcessMessages(npm_install);

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
