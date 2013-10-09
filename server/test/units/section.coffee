assert = require('chai').assert
helpers = require '../helpers'
Q = require('q')

suite('Section')
test('.create', (done) ->
  Section = require('../../models/section').model

  section = new Section(title: 'Head Garments and Sea Vessels')
  section.save (err, section) ->
    if err?
      throw 'Section saving failed'

    Section.count (err, count) ->
      if err?
        throw err
        throw 'Failed to find Section'

      assert.equal 1, count
      done()
)

test('.getValidationErrors should return 0 errors if attributes have an indicator id', ->
  Section = require('../../models/section').model
  errors = Section.getValidationErrors(
    indicator: 5
  )
  assert.lengthOf errors, 0
)

test('.cloneNarrativesFrom when given a section id of a section with a narrative
  should duplicate that narrative,
  relate it to the new section,
  and assign it a new id', (done) ->
  originalSection = originalNarrative = newSection = null

  Q.nfcall(
    helpers.createSection
  ).then((section) ->
    originalSection = section

    Q.nfcall(
      helpers.createNarrative, {
        section: section
        content: "Some test content"
      }
    )
  ).then((narrative) ->
    originalNarrative = narrative

    Q.nfcall(
      helpers.createSection
    )
  ).then((section) ->
    newSection = section

    newSection.cloneNarrativesFrom(section.id)
  ).then( ->
    Q.nsend(
      Narrative.find(section: newSection), 'exec'
    )
  ).then( (clonedNarratives) ->

    assert.lengthOf clonedNarratives, 1, "Expected to have one narrative cloned to new section"
    clonedNarrative = clonedNarratives[0]

    assert.strictEqual clonedNarrative.content, originalNarrative.content,
      "Expected cloned narrative to have the same content as original narrative"

    assert.notStrictEqual clonedNarrative.id, originalNarrative.id,
      "Expected cloned narrative to have a different ID to the original narrative"

  ).fail((err) ->
    console.error err
    throw err
  )
)
