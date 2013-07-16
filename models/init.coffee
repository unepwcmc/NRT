Sequelize = require("sequelize-mysql").sequelize
mysql = require("sequelize-mysql").mysql
sequelize = new Sequelize("NRT", "nrt", "password",
  
  # mysql is the default dialect, but you know...
  # for demo purporses we are defining it nevertheless :)
  # so: we want mysql!
  dialect: "mysql"
)

console.log sequelize

exports.sequelize = sequelize

