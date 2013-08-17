assert = require('chai').assert
helpers = require '../helpers'

suite('Section')
test('.getValidationErrors should return 0 errors if attributes have an indicator id', ->
  Section = require '../../models/section'
  errors = Section.getValidationErrors(
    indicator: 5
  )
  assert.lengthOf errors, 0
)
