assert = require('chai').assert
helpers = require('../helpers')
async = require('async')
_ = require('underscore')

Permission = require('../../models/permission').model

suite('Permission')

test('.create', (done) ->
  theUser = null
  helpers.createUser()
    .then( (user) ->
      theUser = user
      helpers.createTheme()
    ).done( (theme) ->
      permissionAttributes =
        user: theUser.id
        ability: 'read'
        permittable: theme.id
        permittable_type: "Theme"

      permission = new Permission(permissionAttributes)
      permission.save (err, permission) ->
        if err?
          throw 'Permission creation failed'

        Permission.count (err, count) ->
          if err?
            throw 'Could not find created permission'

          assert.equal 1, count
          done()
    )
)
