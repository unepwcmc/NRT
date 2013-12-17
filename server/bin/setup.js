var CommandRunner = require('./command-runner')
var PARENT_DIR = process.cwd() + "/../";

process.chdir(PARENT_DIR + '/client/');

console.log("##### Installing client npm libs #####");
npm_install = CommandRunner.spawn('npm', ['install']);

npm_install.on('close', function(code) {
  if (code === 0) {

    // Compile assets
    console.log("#### Compiling assets #####");
    grunt = CommandRunner.spawn('grunt');

    grunt.on('close', function(code) {
      if (code === 0) {
        process.chdir('../server/');

        console.log("##### Installing server npm libs #####");
        npm_install = CommandRunner.spawn('npm', ['install']);

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
