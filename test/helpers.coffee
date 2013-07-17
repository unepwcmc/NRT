teardownDb = ->
  sequelize.sync({force: true})

exports.beforeGlobal = ->
  teardownDb()
